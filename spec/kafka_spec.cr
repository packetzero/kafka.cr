require "./spec_helper"

describe Kafka do

#  it "get version" do
#    v = LibKafkaC.version()
#    pstr = LibKafkaC.version_str()
#    s = String.new(pstr)
#    puts "version:#{v.to_s(16)} str:'#{s}'"
#    false.should eq(true)
#  end

#  it "can create new handles" do
#    lenErrStr = 128
#    pErrStr = LibC.malloc(lenErrStr).as(UInt8*)
#
#    conf_handle = LibKafkaC.conf_new()
#    unless conf_handle
#      0_u64.should_not eq conf_handle
#      next
#    end

#    res = LibKafkaC.conf_set(conf_handle, "bootstrap.servers", "10.0.20.211:9092", pErrStr, lenErrStr)
#    unless LibKafkaC::ConfResult::OK == res
#      puts "Failed to set config"
#    end

#    LibKafkaC.conf_set_dr_msg_cb conf_handle, ->(rk : LibKafkaC::KafkaHandle, msg : Void*, opaque : Void*) {
#
#      str = String.new LibKafkaC.err2str(LibKafkaC.last_error())
#      puts "DRCallback #{str}" #err:#{err} payload_len:#{len}"
#    }

#    handle = LibKafkaC.kafka_new(LibKafkaC::TYPE_PRODUCER, conf_handle, pErrStr, lenErrStr)
#    if handle == 0_u64
#      puts "Error allocating new kafka handle"
#    end

#    topic = LibKafkaC.topic_new handle, "mytopic4", nil
#    if topic == 0_u64
#      puts "Error allocation new topic handle"
#    end

#    key = "cr-#{Time.now.epoch}"
#    msg = "Some string value here"

#    res = LibKafkaC.produce(topic, LibKafkaC::PARTITION_UNASSIGNED, LibKafkaC::MsgFlags::F_COPY, msg.to_unsafe, msg.size,
#            nil, 0, nil) #key.to_unsafe, key.size, nil )
#    if res == -1
#      puts "Error, produce() returned -1"
#      name = String.new LibKafkaC.topic_name(topic)
#      str = String.new LibKafkaC.err2str(LibKafkaC.last_error())
#      puts "Failed to produce to topic '#{name}':#{str}"
#    end

#    LibKafkaC.poll(handle, 0)
#    LibKafkaC.flush(handle, 10 * 1000)

#    (1..10).each {
#      LibKafkaC.poll(handle, 500)
#    }

#    LibKafkaC.topic_destroy(topic)

#    LibKafkaC.kafka_destroy(handle) unless handle == 0_u64
#    LibKafkaC.conf_destroy(conf_handle)

#    LibC.free(pErrStr)
#  end



end
