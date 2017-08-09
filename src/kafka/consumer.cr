require "./kafka/*"


module Kafka

  # represents a kafka consumer
  class Consumer

    # creates a new kafka handle using provided config.
    # Throws exception on error
    def initialize(conf : Config,
      @partition : Int32 = 0, @offset : Int64 = LibKafkaC::OFFSET_END,
      topic_name : String? = nil)
      @running = false

      @pErrStr = LibC.malloc(ERRLEN).as(UInt8*)
      @handle = LibKafkaC.kafka_new(LibKafkaC::TYPE_CONSUMER, conf, @pErrStr, ERRLEN)
      raise "Kafka: Unable to create new consumer" if @handle == 0_u64

      set_topic(topic_name) if topic_name

    end

    # Set the topic to use for *produce()* calls.
    # Raises exception on error.
    def set_topic(name : String)
      raise "Can't set topic while running." if @running

      @topic = LibKafkaC.topic_new @handle, name, nil
      raise "Kafka: unable to allocate topic instance #{name}" if @topic == 0_u64
    end

    def set_offset(offset : Int64)
      raise "Can't set offset while running." if @running

      @offset = offset
    end

    def set_partition(value : Int32)
      raise "Can't set partition while running." if @running

      @partition = value
    end

    # dequeues a single message
    # Will start consume session, if not already started.
    # returns message or nil
    def consume(timeout_ms : Int32 = 25) : Message?

      raise "No topic set" unless @topic

      unless @running
        puts "Calling consume_start(#{String.new LibKafkaC.topic_name(@topic)}, #{@partition},#{@offset})"
        res = LibKafkaC.consume_start(@topic, @partition, @offset)
        if res < 0
          str = "" #String.new LibKafkaC.err2str(LibKafkaC.last_error())
          raise "Failed to start consumer: #{str}" if res < 0
        end
      end

      @running = true

      puts "Calling consume(#{String.new LibKafkaC.topic_name(@topic)},#{@partition})"
      msg = LibKafkaC.consume @topic, @partition, timeout_ms

      return Message.new msg
    end


    # Calls *flush(1000)* and will stop polling fiber, if running.
    def stop()
      raise "Session not active" unless @running

      @running = false

      LibKafkaC.consume_stop(@topic, @partition)
    end

    # returns true if a consumer session is active
    def running() : Bool
      @running
    end

    # :nodoc:
    def finalize()
      begin
        LibC.free(@pErrStr)

        LibKafkaC.topic_destroy(@topic) if @topic

        LibKafkaC.kafka_destroy(@handle) if @handle
      end
    end

    # :nodoc:
    def to_unsafe
      return @handle
    end

  end

#  Signal.from_value(6).trap do |sig|
#    puts "Kafka.Consumer Signal received #{sig}"
#  end

end
