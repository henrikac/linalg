# linalg

Library that makes it easy to do linear algebra in Crystal.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     linalg:
       github: henrikac/linalg
   ```

2. Run `shards install`

## Usage

#### Basic vector usage
```crystal
require "linalg"

vec1 = Linalg::Vector.new([5, 10, 15])
vec2 = Linalg::Vector.new([10, 10, 10])

vec_add = vec1 + vec2
vec_add # => [15, 20, 25]

vec_sub = vec1 - vec2
vec_sub # => [-5, 0, 5]

scaled_vec = vec1 * 3

scaled_vec.each do |elem|
  puts elem
end

# will output
# 15
# 30
# 45
```

## Contributing

1. Fork it (<https://github.com/henrikac/linalg/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Henrik Christensen](https://github.com/henrikac) - creator and maintainer
