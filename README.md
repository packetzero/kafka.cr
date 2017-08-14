# kafka.cr
Crystal-lang wrapper for the 
[librdkafka](https://github.com/edenhill/librdkafka) C-library
[Apache Kafka](https://kafka.apache.org/) client.
Contributions welcome.

NOTE: there are a couple of other kafka.cr projects.  If I had seen them, I would have worked with them or contributed to them instead.  In any case, this was a good way to help me learn the C-bindings of Crystal.
 - [decioferreira/kafka.cr](https://github.com/decioferreira/kafka.cr)
 - [maiha/kafka.cr](https://github.com/maiha/kafka.cr)

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

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/packetzero/kafka.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [packetzero](https://github.com/packetzero) Alex Malone - creator, maintainer
