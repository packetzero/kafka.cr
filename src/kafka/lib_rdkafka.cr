lib LibC
  # need this for rd_kafka_dump()
  fun fdopen = fdopen(fd: Int32, mode: UInt8*) : Void*    # FILE *
end

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
  alias FileHandle = Void *  # TODO: already defined in LibC?
  alias TopicPartitionList = Void *
  alias TopicPartition = Void*
  alias MessagePtr = Void*

  TYPE_PRODUCER = 0
  TYPE_CONSUMER = 1

#enum ConfResult
#  UNKNOWN = -2 #, /**< Unknown configuration name. */
#  INVALID = -1 #, /**< Invalid configuration value. */
#  OK = 0       # /**< Configuration okay */
#end

  OK = 0

  enum ResponseError
    #/* Internal errors to rdkafka: */
    #/** Begin internal error codes */
    BEGIN_INTERNAL_ERROR = -200
    #/** Received message is incorrect */
    BAD_MSG = -199
    #/** Bad/unknown compression */
    BAD_COMPRESSION = -198
    #/** Broker is going away */
    DESTROY = -197
    #/** Generic failure */
    FAIL = -196
    #/** Broker transport failure */
    TRANSPORT = -195
    #/** Critical system resource */
    CRIT_SYS_RESOURCE = -194
    #/** Failed to resolve broker */
    RESOLVE = -193
    #/** Produced message timed out*/
    MSG_TIMED_OUT = -192
    #/** Reached the end of the topic+partition queue on
    # * the broker. Not really an error.
    # * This event is disabled by default,
    # * see the `enable.partition.eof` configuration property. */
    PARTITION_EOF = -191
    # /** Permanent: Partition does not exist in cluster. */
    UNKNOWN_PARTITION = -190
    #/** File or filesystem error */
    FS = -189
    #/** Permanent: Topic does not exist in cluster. */
    UNKNOWN_TOPIC = -188
    #/** All broker connections are down. */
    ALL_BROKERS_DOWN = -187
    #/** Invalid argument, or invalid configuration */
    INVALID_ARG = -186
    #/** Operation timed out */
    TIMED_OUT = -185
    #/** Queue is full */
    QUEUE_FULL = -184
    #/** ISR count < required.acks */
    ISR_INSUFF = -183
    #/** Broker node update */
    NODE_UPDATE = -182
    #/** SSL error */
    SSL = -181
    #/** Waiting for coordinator to become available. */
    WAIT_COORD = -180
    #/** Unknown client group */
    UNKNOWN_GROUP = -179
    #/** Operation in progress */
    IN_PROGRESS = -178
    #/** Previous operation in progress, wait for it to finish. */
    PREV_IN_PROGRESS = -177
    #/** This operation would interfere with an existing subscription */
    EXISTING_SUBSCRIPTION = -176
    #/** Assigned partitions (rebalance_cb) */
    ASSIGN_PARTITIONS = -175
    #/** Revoked partitions (rebalance_cb) */
    REVOKE_PARTITIONS = -174
    #/** Conflicting use */
    CONFLICT = -173
    #/** Wrong state */
    STATE = -172
    #/** Unknown protocol */
    UNKNOWN_PROTOCOL = -171
    #/** Not implemented */
    NOT_IMPLEMENTED = -170
    #/** Authentication failure*/
    AUTHENTICATION = -169
    #/** No stored offset */
    NO_OFFSET = -168
    #/** Outdated */
    OUTDATED = -167
    #/** Timed out in queue */
    TIMED_OUT_QUEUE = -166
    #/** Feature not supported by broker */
    UNSUPPORTED_FEATURE = -165
    #/** Awaiting cache update */
    WAIT_CACHE = -164
    #/** Operation interrupted (e.g., due to yield)) */
    INTR = -163
    #/** Key serialization error */
    KEY_SERIALIZATION = -162
    #/** Value serialization error */
    VALUE_SERIALIZATION = -161
    #/** Key deserialization error */
    KEY_DESERIALIZATION = -160
    #/** Value deserialization error */
    VALUE_DESERIALIZATION = -159
    #/** Partial response */
    PARTIAL = -158
    #/** Modification attempted on read-only object */
    READ_ONLY = -157
    #/** No such entry / item not found */
    NOENT = -156
    #/** Read underflow */
    UNDERFLOW = -155
    #/** Invalid type */
    INVALID_TYPE = -154
    #/** Retry operation */
    RETRY = -153
    #/** Purged in queue */
    PURGE_QUEUE = -152
    #/** Purged in flight */
    PURGE_INFLIGHT = -151
    #/** Fatal error: see rd_kafka_fatal_error() */
    FATAL = -150
    #/** Inconsistent state */
    INCONSISTENT = -149
    #/** Gap-less ordering would not be guaranteed if proceeding */
    GAPLESS_GUARANTEE = -148
    #/** Maximum poll interval exceeded */
    MAX_POLL_EXCEEDED = -147
    #/** Unknown broker */
    UNKNOWN_BROKER = -146
    #/** Functionality not configured */
    NOT_CONFIGURED = -145
    #/** Instance has been fenced */
    FENCED = -144
    #/** Application generated error */
    APPLICATION = -143

    #/** End internal error codes */
    END_INTERNAL_ERROR = -100

    #/* Kafka broker errors: */
    #/** Unknown broker error */
    UNKNOWN = -1
    #/** Success */
    NO_ERROR = 0
    #/** Offset out of range */
    OFFSET_OUT_OF_RANGE = 1
    #/** Invalid message */
    INVALID_MSG = 2
    #/** Unknown topic or partition */
    UNKNOWN_TOPIC_OR_PART = 3
    #/** Invalid message size */
    INVALID_MSG_SIZE = 4
    #/** Leader not available */
    LEADER_NOT_AVAILABLE = 5
    #/** Not leader for partition */
    NOT_LEADER_FOR_PARTITION = 6
    #/** Request timed out */
    REQUEST_TIMED_OUT = 7
    #/** Broker not available */
    BROKER_NOT_AVAILABLE = 8
    #/** Replica not available */
    REPLICA_NOT_AVAILABLE = 9
    #/** Message size too large */
    MSG_SIZE_TOO_LARGE = 10
    #/** StaleControllerEpochCode */
    STALE_CTRL_EPOCH = 11
    #/** Offset metadata string too large */
    OFFSET_METADATA_TOO_LARGE = 12
    #/** Broker disconnected before response received */
    NETWORK_EXCEPTION = 13
    #/** Coordinator load in progress */
    COORDINATOR_LOAD_IN_PROGRESS = 14
    #/** Coordinator not available */
    COORDINATOR_NOT_AVAILABLE = 15
    #/** Not coordinator */
    NOT_COORDINATOR = 16
    #/** Invalid topic */
    TOPIC_EXCEPTION = 17
    #/** Message batch larger than configured server segment size */
    RECORD_LIST_TOO_LARGE = 18
    #/** Not enough in-sync replicas */
    NOT_ENOUGH_REPLICAS = 19
    #/** Message(s) written to insufficient number of in-sync replicas */
    NOT_ENOUGH_REPLICAS_AFTER_APPEND = 20
    #/** Invalid required acks value */
    INVALID_REQUIRED_ACKS = 21
    #/** Specified group generation id is not valid */
    ILLEGAL_GENERATION = 22
    #/** Inconsistent group protocol */
    INCONSISTENT_GROUP_PROTOCOL = 23
    #/** Invalid group.id */
    INVALID_GROUP_ID = 24
    #/** Unknown member */
    UNKNOWN_MEMBER_ID = 25
    #/** Invalid session timeout */
    INVALID_SESSION_TIMEOUT = 26
    #/** Group rebalance in progress */
    REBALANCE_IN_PROGRESS = 27
    #/** Commit offset data size is not valid */
    INVALID_COMMIT_OFFSET_SIZE = 28
    #/** Topic authorization failed */
    TOPIC_AUTHORIZATION_FAILED = 29
    #/** Group authorization failed */
    GROUP_AUTHORIZATION_FAILED = 30
    #/** Cluster authorization failed */
    CLUSTER_AUTHORIZATION_FAILED = 31
    #/** Invalid timestamp */
    INVALID_TIMESTAMP = 32
    #/** Unsupported SASL mechanism */
    UNSUPPORTED_SASL_MECHANISM = 33
    #/** Illegal SASL state */
    ILLEGAL_SASL_STATE = 34
    #/** Unuspported version */
    UNSUPPORTED_VERSION = 35
    #/** Topic already exists */
    TOPIC_ALREADY_EXISTS = 36
    #/** Invalid number of partitions */
    INVALID_PARTITIONS = 37
    #/** Invalid replication factor */
    INVALID_REPLICATION_FACTOR = 38
    #/** Invalid replica assignment */
    INVALID_REPLICA_ASSIGNMENT = 39
    #/** Invalid config */
    INVALID_CONFIG = 40
    #/** Not controller for cluster */
    NOT_CONTROLLER = 41
    #/** Invalid request */
    INVALID_REQUEST = 42
    #/** Message format on broker does not support request */
    UNSUPPORTED_FOR_MESSAGE_FORMAT = 43
    #/** Policy violation */
    POLICY_VIOLATION = 44
    #/** Broker received an out of order sequence number */
    OUT_OF_ORDER_SEQUENCE_NUMBER = 45
    #/** Broker received a duplicate sequence number */
    DUPLICATE_SEQUENCE_NUMBER = 46
    #/** Producer attempted an operation with an old epoch */
    INVALID_PRODUCER_EPOCH = 47
    #/** Producer attempted a transactional operation in an invalid state */
    INVALID_TXN_STATE = 48
    #/** Producer attempted to use a producer id which is not
    # *  currently assigned to its transactional id */
    INVALID_PRODUCER_ID_MAPPING = 49
    #/** Transaction timeout is larger than the maximum
    # *  value allowed by the broker's max.transaction.timeout.ms */
    INVALID_TRANSACTION_TIMEOUT = 50
    #/** Producer attempted to update a transaction while another
    # *  concurrent operation on the same transaction was ongoing */
    CONCURRENT_TRANSACTIONS = 51
    #/** Indicates that the transaction coordinator sending a
    # *  WriteTxnMarker is no longer the current coordinator for a
    # *  given producer */
    TRANSACTION_COORDINATOR_FENCED = 52
    #/** Transactional Id authorization failed */
    TRANSACTIONAL_ID_AUTHORIZATION_FAILED = 53
    #/** Security features are disabled */
    SECURITY_DISABLED = 54
    #/** Operation not attempted */
    OPERATION_NOT_ATTEMPTED = 55
    #/** Disk error when trying to access log file on the disk */
    KAFKA_STORAGE_ERROR = 56
    #/** The user-specified log directory is not found in the broker config */
    LOG_DIR_NOT_FOUND = 57
    #/** SASL Authentication failed */
    SASL_AUTHENTICATION_FAILED = 58
    #/** Unknown Producer Id */
    UNKNOWN_PRODUCER_ID = 59
    #/** Partition reassignment is in progress */
    REASSIGNMENT_IN_PROGRESS = 60
    #/** Delegation Token feature is not enabled */
    DELEGATION_TOKEN_AUTH_DISABLED = 61
    #/** Delegation Token is not found on server */
    DELEGATION_TOKEN_NOT_FOUND = 62
    #/** Specified Principal is not valid Owner/Renewer */
    DELEGATION_TOKEN_OWNER_MISMATCH = 63
    #/** Delegation Token requests are not allowed on this connection */
    DELEGATION_TOKEN_REQUEST_NOT_ALLOWED = 64
    #/** Delegation Token authorization failed */
    DELEGATION_TOKEN_AUTHORIZATION_FAILED = 65
    #/** Delegation Token is expired */
    DELEGATION_TOKEN_EXPIRED = 66
    #/** Supplied principalType is not supported */
    INVALID_PRINCIPAL_TYPE = 67
    #/** The group is not empty */
    NON_EMPTY_GROUP = 68
    #/** The group id does not exist */
    GROUP_ID_NOT_FOUND = 69
    #/** The fetch session ID was not found */
    FETCH_SESSION_ID_NOT_FOUND = 70
    #/** The fetch session epoch is invalid */
    INVALID_FETCH_SESSION_EPOCH = 71
    #/** No matching listener */
    LISTENER_NOT_FOUND = 72
    #/** Topic deletion is disabled */
    TOPIC_DELETION_DISABLED = 73
    #/** Leader epoch is older than broker epoch */
    FENCED_LEADER_EPOCH = 74
    #/** Leader epoch is newer than broker epoch */
    UNKNOWN_LEADER_EPOCH = 75
    #/** Unsupported compression type */
    UNSUPPORTED_COMPRESSION_TYPE = 76
    #/** Broker epoch has changed */
    STALE_BROKER_EPOCH = 77
    #/** Leader high watermark is not caught up */
    OFFSET_NOT_AVAILABLE = 78
    #/** Group member needs a valid member ID */
    MEMBER_ID_REQUIRED = 79
    #/** Preferred leader was not available */
    PREFERRED_LEADER_NOT_AVAILABLE = 80
    #/** Consumer group has reached maximum size */
    GROUP_MAX_SIZE_REACHED = 81
    #/** Static consumer fenced by other consumer with same
    # *  group.instance.id. */
    FENCED_INSTANCE_ID = 82
    #/** Eligible partition leaders are not available */
    ELIGIBLE_LEADERS_NOT_AVAILABLE = 83
    #/** Leader election not needed for topic partition */
    ELECTION_NOT_NEEDED = 84
    #/** No partition reassignment is in progress */
    NO_REASSIGNMENT_IN_PROGRESS = 85
    #/** Deleting offsets of a topic while the consumer group is subscribed to it */
    GROUP_SUBSCRIBED_TO_TOPIC = 86
    #/** Broker failed to validate record */
    INVALID_RECORD = 87
    #/** There are unstable offsets that need to be cleared */
    UNSTABLE_OFFSET_COMMIT = 88
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
  payload : UInt8* #void   *payload;           /**< Producer: original message payload.
          #* Consumer: Depends on the value of \c err :
          #* - \c err==0: Message payload.
          #* - \c err!=0: Error string */
  len : LibC::SizeT #size_t  len;               /**< Depends on the value of \c err :
          #* - \c err==0: Message payload length
          #* - \c err!=0: Error string length */
  key : UInt8* #void   *key;               /**< Depends on the value of \c err :
          #* - \c err==0: Optional message key */
  key_len : LibC::SizeT #size_t  key_len;           /**< Depends on the value of \c err :
          #* - \c err==0: Optional message key length*/
  offset : Int64 #int64_t offset;            /**< Consume:
          #    * - Message offset (or offset for error
          #*   if \c err!=0 if applicable).
  _priv : Void*
end

  fun conf_new = rd_kafka_conf_new : ConfHandle
  fun conf_destroy = rd_kafka_conf_destroy(conf: ConfHandle)
  fun conf_set = rd_kafka_conf_set(conf: ConfHandle, name: UInt8*, value: UInt8*, errstr: UInt8*, errstr_size: LibC::SizeT) : Int32

  fun conf_set_dr_msg_cb = rd_kafka_conf_set_dr_msg_cb(conf: ConfHandle, cb: (KafkaHandle, Message*, Void* ) -> )

  fun topic_conf_new = rd_kafka_topic_conf_new : TopicConf
  fun topic_conf_destroy = rd_kafka_topic_conf_destroy(tc : TopicConf)
  fun conf_set_default_topic_conf = rd_kafka_conf_set_default_topic_conf(conf: ConfHandle, tc: TopicConf) : Int32
  fun topic_conf_set = rd_kafka_topic_conf_set(tc: TopicConf, name: UInt8*, value: UInt8*, errstr: UInt8*, errstr_size: LibC::SizeT) : Int32

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

  fun consume = rd_kafka_consume(topic: Topic, partition: Int32, timeout_ms: Int32) : Message*

  fun consumer_poll = rd_kafka_consumer_poll (rk: KafkaHandle, timeout_ms: Int32) : Message*
  fun poll_set_consumer = rd_kafka_poll_set_consumer (rk: KafkaHandle) : Int32
  fun brokers_add = rd_kafka_brokers_add(rk: KafkaHandle, broker_list: UInt8*) : Int32
  fun consumer_close = rd_kafka_consumer_close (rk: KafkaHandle) : Int32
  fun message_destroy = rd_kafka_message_destroy (msg: Message*)
  fun wait_destroyed = rd_kafka_wait_destroyed(timeout_ms: Int32) : Int32
  fun dump = rd_kafka_dump(file: FileHandle, rk: KafkaHandle)

  fun topic_partition_list_new = rd_kafka_topic_partition_list_new(size: Int32) : TopicPartitionList
  fun topic_partition_list_add = rd_kafka_topic_partition_list_add(tplist: TopicPartitionList, topic: UInt8*, partition: Int32) : Void* # TopicPartition
  fun topic_partition_list_destroy = rd_kafka_topic_partition_list_destroy(tplist: TopicPartitionList)
  fun assign = rd_kafka_assign(rk: KafkaHandle, topics: TopicPartitionList) : Int32
  fun subscribe = rd_kafka_subscribe(rk: KafkaHandle, subscription: TopicPartitionList) : Int32

  fun poll = rd_kafka_poll(rk: KafkaHandle, timeout_ms: Int32) : Int32
  fun flush = rd_kafka_flush(rk: KafkaHandle, timeout_ms: Int32) : Int32

  fun last_error = rd_kafka_last_error() : Int32
  fun err2str = rd_kafka_err2str(code : Int32) : UInt8*
  fun errno2err = rd_kafka_errno2err(errno : Int32) : ResponseError

  fun conf_set_log_cb = rd_kafka_conf_set_log_cb(conf: ConfHandle, cb: (KafkaHandle, Int32, UInt32, UInt8*) -> )
  fun set_log_level = rd_kafka_set_log_level(kh: KafkaHandle, level: Int32)

end
