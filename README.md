# linalg

Library that makes it easy to do linear algebra in Crystal.  

For now Linalg only supports `Number::Primitive` types.

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

#### Basic matrix usage
```crystal
require "linalg"

mat1 = Linalg::Matrix.new([[1, 2, 3], [4, 5, 6]])
mat2 = Linalg::Matrix.new([[1.0, 2.0], [3.0, 4.0]])

mat1 << Linalg::Vector.new([7, 8, 9])
mat2 << [5.0, 6.0]

mat1 # => [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
mat2 # => [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]

mat2.rows # => 3
mat2.columns # => 2

mat1[1] # => [4, 5, 6]
mat1[2, 0] # => 7

mat1 * 2 # => [[2, 4, 6], [8, 10, 12], [14, 16, 18]]
```

#### Matrix addition and subtraction
Matrix addition and subtraction requires that both matrices and the dimensions, e.g. if matrix *A* is a *m x n* matrix then matrix *B* must also be *m x n* matrix.

```crystal
mat1 = Linalg::Matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
mat2 = Linalg::Matrix.new([[4, -1, 6], [2, 9, -3], [-4, 5, 1]])

mat3 = mat1 + mat2
mat3 # => [[5, 1, 9], [6, 14, 3], [3, 13, 10]]

mat4 = mat1 - mat2
mat4 # => [[-3, 3, -3], [2, -4, 9], [11, 3, 8]]
```

#### Matrix-vector and vector-matrix multiplication
For matrix-vector multiplication the vector must have the same size as the number of columns in the matrix.
```crystal
vec = Linalg::Vector.new([2, 3, 4])
mat = Linalg::Matrix.new([[5, 2, 6], [7, 2, 5], [1, 4, 2]])
mat * vec # => [40, 40, 22]
```

Vector-matrix multiplication requires the vector to have the same size as the number of rows in the matrix.
```crystal
vec = Linalg::Vector.new([2, 3, 4])
mat = Linalg::Matrix.new([[5, 2, 6], [7, 2, 5], [1, 4, 2]])
vec * mat # => [35, 26, 35]
```

## Contributing

1. Fork it (<https://github.com/henrikac/linalg/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Henrik Christensen](https://github.com/henrikac) - creator and maintainer
