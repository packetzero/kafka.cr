module Kafka
  ERRLEN=128

  class Config

    def initialize()
      @pErrStr = LibC.malloc(ERRLEN).as(UInt8*)
      @conf_handle = LibKafkaC.conf_new()
      raise "Failed to allocate Kafka Config" unless @conf_handle
    end

    def finalize()
      begin
        LibC.free(@pErrStr)
        #LibKafkaC.conf_destroy(@conf_handle) if @conf_handle
      end
    end

    def to_unsafe
      return @conf_handle
    end

    def set(name : String, value : String)
      res = LibKafkaC.conf_set(@conf_handle, name, value, @pErrStr, ERRLEN)
      raise "Kafka.Config: set('#{name}') failed: #{String.new @pErrStr}" unless LibKafkaC::ConfResult::OK == res
    end

    def set_msg_callback(cb : Proc(LibKafkaC::KafkaHandle, Void*, Void*) )
      LibKafkaC.conf_set_dr_msg_cb @conf_handle, cb
    end
  end

end
