require "./kafka/*"


module Kafka

  class Producer
    def initialize(conf : Config)
      @pErrStr = LibC.malloc(ERRLEN).as(UInt8*)
      @handle = LibKafkaC.kafka_new(LibKafkaC::TYPE_PRODUCER, conf, pErrStr, ERRLEN)
      raise "Kafka: Unable to create new producer" if @handle == 0_u64
    end

    def set_topic(name : String)
      @topic = LibKafkaC.topic_new @handle, name, nil
      raise "Kafka: unable to allocate topic instance #{name}" if @topic == 0_u64
    end

    def produce(msg : String, partition: Int32?, key: String?)
      raise "No topic set" unless @topic
      part = partition || LibKafkaC::PARTITION_UNASSIGNED
      res = LibKafkaC.produce(@topic, part, LibKafkaC::MsgFlags::F_COPY, msg.to_unsafe, msg.size,
              key, key.nil? 0 : key.size, nil)
      raise "Failed to enqueue message" if res == -1

      LibKafkaC.poll(@handle, 0)
      LibKafkaC.flush(@handle, 10 * 1000)
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

end
