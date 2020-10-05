require "./lib_rdkafka.cr"
require "./config.cr"
require "./errors"

module Kafka
  # Provides insights whether sending a message that has been previously
  # enqueued was successful or not.
  struct DeliveryReport
    getter err

    def initialize(@err : LibKafkaC::ResponseError)
    end

    def ok?
      @err.no_error?
    end

    def failed?
      !ok?
    end

    def error_message : String
      Kafka.err2str(@err)
    end

    def to_s(io)
      if ok?
        io << "OK"
      else
        io << "Error: " << @err << " (" << error_message << ')'
      end
    end
  end

  # Internal class to prevent the GC from deleting the objects from the callback.
  class PreventGC
    @prevent_gc = Set(Pointer(Void)).new
    @prevent_gc_mutex = Mutex.new

    def protect_from_gc(box : Pointer(Void)) : Pointer(Void)
      @prevent_gc_mutex.synchronize { @prevent_gc.add(box) }
      box
    end

    def allow_gc(box : Pointer(Void)) : Nil
      @prevent_gc_mutex.synchronize { @prevent_gc.delete(box) }
    end
  end

  # represents a kafka producer
  class Producer
    class NativeResources
      getter handle
      getter topic : LibKafkaC::Topic?
      @delivery_report_handler : Proc(LibKafkaC::KafkaHandle, LibKafkaC::Message*, Void*, Nil)?
      @prevent_gc = PreventGC.new

      def initialize(conf : Config, install_delivery_report_cb : Bool)
        # Pushing a message to the queue does not guarantee that the message gets
        # successfully delivered. To gain certainty, Kafka allows to install a
        # callback with will include a status code indication whether sending
        # was succesful.
        if install_delivery_report_cb
          callback = ->(_handle : LibKafkaC::KafkaHandle, kafka_message : LibKafkaC::Message*, _conf_opaque : Void*) {
            msg = kafka_message.value
            boxed_arg = msg._priv
            channel, prevent_gc = Box({Channel(DeliveryReport), PreventGC}).unbox(boxed_arg)
            prevent_gc.allow_gc(boxed_arg)
            begin
              channel.send(DeliveryReport.new(LibKafkaC::ResponseError.new(msg.err)))
            rescue Channel::ClosedError
              # caller is no longer interested in the delivery report
            end
            nil
          }
          conf.set_msg_callback(callback)
          @delivery_report_handler = callback # prevent GC collection
        end

        @err_str_ptr = LibC.malloc(ERRLEN).as(UInt8*)
        @handle = LibKafkaC.kafka_new(LibKafkaC::TYPE_PRODUCER, conf, @err_str_ptr, ERRLEN)
        raise "Kafka: Unable to create new producer" if @handle == 0_u64
      end

      def init_topic(topic : LibKafkaC::Topic)
        raise "Topic already initialized" if @topic
        @topic = topic
      end

      def has_delivery_report_handler?
        !@delivery_report_handler.nil?
      end

      def box(channel : Channel(DeliveryReport)) : Pointer(Void)
        @prevent_gc.protect_from_gc(Box.box({channel, @prevent_gc}))
      end

      def finalize
        @topic.try { |x| LibKafkaC.topic_destroy(x) }
        LibKafkaC.kafka_destroy(@handle) unless @handle == 0_u64
        LibC.free(@err_str_ptr)
      end
    end

    class PollingFiber
      def initialize(@native : NativeResources, @polling_interval : Time::Span)
        @stopped = Atomic(Int32).new(0)
      end

      def start
        spawn do
          while !stopped?
            LibKafkaC.poll(@native.handle, 0)
            sleep @polling_interval
          end
        end
      end

      def stopped?
        @stopped.get != 0
      end

      def stop
        @stopped.set(1)
      end

      def finalize
        @stopped.set(1)
      end
    end

    @polling_fiber = Atomic(PollingFiber?).new(nil)
    getter polling_interval

    # creates a new kafka handle using provided config.
    # Throws exception on error
    def initialize(conf : Config, *, install_delivery_report_cb = false, @polling_interval : Time::Span = 200.milliseconds)
      @native = NativeResources.new(conf, install_delivery_report_cb)
    end

    # Set the topic to use for *produce()* calls.
    # Raises exception on error.
    def set_topic(name : String)
      topic = LibKafkaC.topic_new(@native.handle, name, nil)
      raise "Kafka: unable to allocate topic instance #{name}" if topic == 0_u64
      @native.init_topic(topic)
    end

    # enqueues *msg*
    # Will start internal polling fiber if not already started.
    # Returns true on success.  Raises exception otherwise
    def produce(msg : String | Bytes, partition : Int32 = LibKafkaC::PARTITION_UNASSIGNED, key : String? = nil, flags : Int32 = LibKafkaC::MSG_FLAG_COPY) : Bool
      unless topic = @native.topic
        raise "No topic set"
      end
      part = partition || LibKafkaC::PARTITION_UNASSIGNED

      res = LibKafkaC.produce(topic, part, flags, msg.to_unsafe, msg.size,
        key, (key.nil? ? 0 : key.size), nil)
      if res != LibKafkaC::OK
        raise IO::Error.new("Failed to enqueue message (errno: #{Errno.value})")
      end

      ensure_polling_fiber_is_running
      true
    end

    # Similar to `produce`, but allows to detect whether sending was successful or not.
    # There are two phases that can fail (enqueuing and asynchronous sending):
    #
    # First, if the message cannot be enqueued, an exception will be thrown immediately.
    # Otherwise, the sending with occur in the background. To see the results, a channel
    # will be returned which will eventually receive the delivery report.
    #
    # To receive the delivery report, we are building on a Kafka's user callbacks.
    # If you want to use this function, make sure that the option was enabled
    # in the constructor (`install_delivery_report_cb` should be `true`).
    #
    # Note: Callbacks will come with a performance penality, so if throughput is more
    # important in your use case then detecting errors, using the fire-and-forget
    # `produce` method is recommended instead.
    #
    # Will start the internal polling fiber if not already started.
    def produce_with_delivery_report(msg : String | Bytes, *, partition : Int32 = LibKafkaC::PARTITION_UNASSIGNED, key : String? = nil, flags : Int32 = LibKafkaC::MSG_FLAG_COPY) : Channel(DeliveryReport)
      raise "No topic set" unless topic = @native.topic
      raise "Pass 'install_delivery_report_cb=true' to the constructor" unless @native.has_delivery_report_handler?

      part = partition || LibKafkaC::PARTITION_UNASSIGNED

      delivery_report_channel = Channel(DeliveryReport).new(1)
      delivery_report_callback_arg = @native.box(delivery_report_channel)

      res = LibKafkaC.produce(topic, part, flags, msg.to_unsafe, msg.size,
        key, (key.nil? ? 0 : key.size), delivery_report_callback_arg)
      if res != LibKafkaC::OK
        raise IO::Error.new("Failed to enqueue message (errno: #{Errno.value})")
      end
      ensure_polling_fiber_is_running
      delivery_report_channel
    end

    # The Kafka API requires that we call *poll* at regular intervals.
    private def ensure_polling_fiber_is_running
      @polling_fiber.get.try do |old_fiber|
        return unless old_fiber.stopped?
      end

      new_fiber = PollingFiber.new(@native, @polling_interval)
      _, changed = @polling_fiber.compare_and_set(nil, new_fiber)
      new_fiber.start if changed
    end

    # Calls *flush* and will stop polling the fiber if running.
    def stop(timeout = 30.seconds)
      if old_fiber = @polling_fiber.get
        @polling_fiber.compare_and_set(old_fiber, nil)
        old_fiber.stop
      end
      flush(timeout)
    end

    def flush(timeout = 10.second) : Nil
      case err = LibKafkaC::ResponseError.new(LibKafkaC.flush(@native.handle, timeout.total_milliseconds))
      when .no_error?
        nil
      when .timed_out?
        raise IO::TimeoutError.new
      else
        raise KafkaException.new("Unexpected error when flushing messages", err)
      end
    end

    @[Deprecated("Use `#flush(Time::TimeSpan)` instead")]
    def flush(timeout_ms : Int32)
      LibKafkaC.flush(@native.handle, timeout_ms)
    end

    # returns true if polling fiber is running
    def polling : Bool
      @polling_fiber.get
    end

    # :nodoc:
    def to_unsafe
      @native.handle
    end
  end
end
