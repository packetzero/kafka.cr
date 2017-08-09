@[Link("rdkafka")]
lib LibKafkaC

  # C API documented here:
  # https://github.com/edenhill/librdkafka/blob/master/src/rdkafka.h

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

MSG_FLAG_FREE = 0x1    # Delegate freeing of payload to rdkafka
MSG_FLAG_COPY = 0x2    # rdkafka will make a copy of the payload.
MSG_FLAG_BLOCK = 0x4   # Block produce*() on message queue full

OFFSET_BEGINNING = -2_i64  # /**< Start consuming from beginning of
OFFSET_END       = -1_i64  # /**< Start consuming from end of kafka


PARTITION_UNASSIGNED = -1

struct Message
  err : Int32 #rd_kafka_resp_err_t err;   /**< Non-zero for error signaling. */
  rkt : Topic #rd_kafka_topic_t *rkt;     /**< Topic */
  partition : Int32 #int32_t partition;         /**< Partition */
  payload : Void* #void   *payload;           /**< Producer: original message payload.
          #* Consumer: Depends on the value of \c err :
          #* - \c err==0: Message payload.
          #* - \c err!=0: Error string */
  len : LibC::SizeT #size_t  len;               /**< Depends on the value of \c err :
          #* - \c err==0: Message payload length
          #* - \c err!=0: Error string length */
  key : Void* #void   *key;               /**< Depends on the value of \c err :
          #* - \c err==0: Optional message key */
  ken_len : LibC::SizeT #size_t  key_len;           /**< Depends on the value of \c err :
          #* - \c err==0: Optional message key length*/
  offset : Int64 #int64_t offset;            /**< Consume:
          #    * - Message offset (or offset for error
          #*   if \c err!=0 if applicable).
  _priv : Void*
end

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

  fun produce = rd_kafka_produce(topic: Topic, partition: Int32, msgflags: Int32, payload: Void*, len: LibC::SizeT,
          key: Void*, keylen: LibC::SizeT, user_callback_arg: Void* ) : Int32

  # returns 0 on success or -1 on error in which case errno is set accordingly:
  fun consume_start = rd_kafka_consume_start(topic: Topic, partition: Int32, offset: Int64) : Int32

  # returns 0 on success or -1 on error (see `errno`).
  fun consume_stop = rd_kafka_consume_stop(topic: Topic, partition: Int32) : Int32

  fun consume = rd_kafka_consume(topic: Topic, partition: Int32, timeout_ms: Int32) : Message

  fun poll = rd_kafka_poll(rk: KafkaHandle, timeout_ms: Int32) : Int32
  fun flush = rd_kafka_flush(rk: KafkaHandle, timeout_ms: Int32)

  fun last_error = rd_kafka_last_error() : Int32
  fun err2str = rd_kafka_err2str(code : Int32) : UInt8*

end
