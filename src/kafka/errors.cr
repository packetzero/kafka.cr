require "./lib_rdkafka.cr"

module Kafka
  def self.err2str(err : Int32 | LibKafkaC::ResponseError) : String
    String.new(LibKafkaC.err2str(err.to_i32))
  end

  def self.normalize_error(err : LibKafkaC::ResponseError) : LibKafkaC::ResponseError
    err
  end

  def self.normalize_error(errno : Errno) : LibKafkaC::ResponseError
    LibKafkaC.errno2err(errno)
  end

  class KafkaException < Exception
    getter err : LibKafkaC::ResponseError

    def initialize(message : String?, err : LibKafkaC::ResponseError | Errno)
      @err = Kafka.normalize_error(err)
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
