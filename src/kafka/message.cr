require "./kafka/*"


module Kafka

  class Message

    def initialize(@msg : LibKafkaC::Message*)
    end

    def payload : Bytes?
      return nil if @msg.null?
      tmp = @msg.value
      return nil if tmp.len == 0
      Bytes.new(tmp.payload, tmp.len)
    end

    def key : Bytes?
      return nil if @msg.null?
      tmp = @msg.value
      return nil if tmp.key_len == 0
      Bytes.new(tmp.key, tmp.key_len)
    end

    def valid?
      !@msg.null?
    end

    def to_unsafe
      @msg
    end

    def finalize()
      LibKafkaC.message_destroy(@msg) unless @msg.null?
    end
  end

end
