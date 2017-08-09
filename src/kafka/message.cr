require "./kafka/*"


module Kafka

  class Message
    def initialize(@msg : LibKafkaC::Message)
    end

    def valid?
      @msg != 0_u64 && @msg.err == 0
    end

    def to_unsafe
      @msg
    end
  end

end
