require "./lib_rdkafka.cr"

module Kafka
  def self.err2str(err : Int32 | LibKafkaC::ResponseError) : String
    String.new(LibKafkaC.err2str(err.to_i32))
  end

  class KafkaException < Exception
    getter err : LibKafkaC::ResponseError

    def initialize(message : String?, @err)
      super(format_error(message, @err))
    end

    private def format_error(message, err)
      if message
        "#{message} (code=#{err})"
      else
        "#{Kafka.err2str(err)} (code=#{err})"
      end
    end
  end
end
