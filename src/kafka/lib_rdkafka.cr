@[Link("rdkafka")]
lib LibKafkaC

  fun version = rd_kafka_version() : Int32
  fun version_str = rd_kafka_version_str() : UInt8*

  alias KafkaHandle = Void *
  alias ConfHandle = Void *
  alias Topic = Void *
  alias TopicConf = Void *

  TYPE_PRODUCER = 0
  TYPE_CONSUMER = 1

enum ConfResult
  UNKNOWN = -2 #, /**< Unknown configuration name. */
  INVALID = -1 #, /**< Invalid configuration value. */
  OK = 0       # /**< Configuration okay */
end

enum MsgFlags
  F_FREE = 0x1    # Delegate freeing of payload to rdkafka
  F_COPY = 0x2    # rdkafka will make a copy of the payload.
  F_BLOCK = 0x4   # Block produce*() on message queue full
end

  PARTITION_UNASSIGNED = -1

  fun conf_new = rd_kafka_conf_new : ConfHandle
  fun conf_destroy = rd_kafka_conf_destroy(conf: ConfHandle)
  fun conf_set = rd_kafka_conf_set(conf: ConfHandle, name: UInt8*, value: UInt8*, errstr: UInt8*, errstr_size: LibC::SizeT) : ConfResult

  fun conf_set_dr_msg_cb = rd_kafka_conf_set_dr_msg_cb(conf: ConfHandle, cb: (KafkaHandle, Void*, Void* ) -> )

  fun topic_conf_new = rd_kafka_topic_conf_new : TopicConf
  fun topic_conf_destroy = rd_kafka_topic_conf_destroy(tc : TopicConf)

  fun topic_new = rd_kafka_topic_new(rk : KafkaHandle, topic_name : UInt8*, topic_conf : TopicConf) : Topic
  fun topic_destroy = rd_kafka_topic_destroy(t : Topic)
  fun topic_name = rd_kafka_topic_name(t: Topic) : UInt8*

  fun kafka_new = rd_kafka_new(t: Int32 , conf: ConfHandle, errstr: UInt8*, errstr_size: LibC::SizeT) : KafkaHandle
  fun kafka_destroy = rd_kafka_destroy(handle: KafkaHandle)

  fun produce = rd_kafka_produce(topic: Topic, partition : Int32, msgflags : Int32, payload: Void*, len: LibC::SizeT,
          key: Void*, keylen: LibC::SizeT, user_callback_arg: Void* ) : Int32

  fun poll = rd_kafka_poll(rk: KafkaHandle, timeout_ms: Int32) : Int32
  fun flush = rd_kafka_flush(rk: KafkaHandle, timeout_ms: Int32)

  fun last_error = rd_kafka_last_error() : Int32
  fun err2str = rd_kafka_err2str(code : Int32) : UInt8*

end
