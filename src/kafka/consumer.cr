require "./kafka/*"


module Kafka

  # represents a kafka (polling) consumer
  # based on:
  # https://github.com/edenhill/librdkafka/blob/master/examples/rdkafka_consumer_example.c
  #
  # Should be initialized in this order before consuming:
  # ```
  #    kafka = Kafka::Consumer.new(conf) # conf should have group.id set
  #    kafka.add_brokers "localhost:9092"
  #    kafka.set_topic_partition "some topic"
  # ```
  class Consumer

    # creates a new kafka handle using provided config.
    # Throws exception on error
    def initialize(@conf : Config)
      @running = false
      @topics = nil

      @pErrStr = LibC.malloc(ERRLEN).as(UInt8*)

      @topic_conf = LibKafkaC.topic_conf_new();

      err = LibKafkaC.topic_conf_set(@topic_conf, "offset.store.method", "broker", @pErrStr, ERRLEN)
      raise "Error setting topic conf offset.store.method #{String.new @pErrStr}" if err != LibKafkaC::OK

      # Set default topic config for pattern-matched topics.
      LibKafkaC.conf_set_default_topic_conf(conf, @topic_conf);

      @handle = LibKafkaC.kafka_new(LibKafkaC::TYPE_CONSUMER, conf, @pErrStr, ERRLEN)
      raise "Kafka: Unable to create new consumer" if @handle.not_nil!.address == 0_u64

    end

    def add_brokers(brokerList : String)
      if 0 == LibKafkaC.brokers_add(@handle, brokerList)
        raise "No valid brokers specified"
      end

      LibKafkaC.poll_set_consumer(@handle)

    end

    # Set the topic to use for *produce()* calls.
    # Raises exception on error.
    def set_topic_partition(name : String, partition : Int32 = 0) #LibKafkaC::PARTITION_UNASSIGNED)
      raise "Can't set topic while running." if @running

      unless @topics
        @topics = LibKafkaC.topic_partition_list_new(1)  # TODO: support multiple
        raise "Error creating topic_partition list" if @topics.not_nil!.address == 0_u64
      end

      LibKafkaC.topic_partition_list_add(@topics, name, partition)

      err = LibKafkaC.assign(@handle, @topics)
      raise "Error assigning topic partitions err=#{err}" if err != 0

    end

    # dequeues a single message
    # Will start consume session, if not already started.
    # returns message or nil
    def consume(timeout_ms : Int32 = 25) : Message?

      raise "No topic set" unless @topics

      @running = true

      msg = LibKafkaC.consumer_poll @handle, timeout_ms

      return Message.new msg
    end


    # closes the consumer if running.
    def stop()
      raise "Session not active" unless @running

      @running = false

      LibKafkaC.consumer_close(@handle)
    end

    # returns true if a consumer session is active
    def running() : Bool
      @running
    end

    # :nodoc:
    def finalize()
      begin

        LibC.free(@pErrStr)

        LibKafkaC.topic_partition_list_destroy(@topics) if @topics

        LibKafkaC.kafka_destroy(@handle) if @handle
      end
    end

    # :nodoc:
    def to_unsafe
      return @handle
    end

  end

end
