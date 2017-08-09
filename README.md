# kafka.cr

STATUS:
 - Simple polling producer works for keys,values that are strings.
 - Consumer has threading issue

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  kafka.cr:
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
