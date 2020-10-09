# archived - Use [https://github.com/philipp-classen/kafka.cr](https://github.com/philipp-classen/kafka.cr)
# kafka.cr
Crystal-lang wrapper for the 
[librdkafka](https://github.com/edenhill/librdkafka) C-library
[Apache Kafka](https://kafka.apache.org/) client.
Contributions welcome.

STATUS:
 - Simple polling producer works for keys,values that are strings.
 - Simple polling consumer works for keys,values that are strings.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  kafka:
    github: packetzero/kafka.cr
```

## Usage

```crystal
require "kafka"
```

See examples in [kafka_examples](https://github.com/packetzero/kafka_examples.cr)

