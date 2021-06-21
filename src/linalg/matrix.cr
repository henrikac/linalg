require "./helpers/**"

class Linalg::Matrix(T)
  # Elements in the matrix
  @elements : Array(Linalg::Vector(T))

  # Number of rows in the matrix.
  @rows : Int32

  # Number of columns in the matrix.
  @columns : Int32

  # Creates a new empty matrix.
  #
  # ```
  # matrix = Linalg::Matrix(Float64).new
  # matrix # => []
  # ```
  def initialize
    {% raise "T must be an integer or a float" unless T < Number::Primitive %}
    @elements = Array(Linalg::Vector(T)).new
    @rows = 0
    @columns = 0
  end

  # Creates a new matrix filled with vectors of the given *elements*.
  #
  # ```
  # matrix = Linalg::Matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
  # matrix # => [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  # ```
  #
  # An `ArgumentError` is raised if the elements in the given array have
  # differents sizes.
  def initialize(elements : Array(Array(T)))
    {% raise "T must be an integer or a float" unless T < Number::Primitive %}
    @elements = Array(Linalg::Vector(T)).new
    @rows = elements.size
    @columns = elements[0].size 

    elements.each do |elem|
      if elem.size != @columns
        raise ArgumentError.new("elements must have the same size")
      end
      @elements << Linalg::Vector(T).new(elem)
    end
  end

  # Creates a new matrix filled with the given *elements*.
  # ```
  # rows = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  # vectors = Array(Linalg::Vector(Int32)).new
  #
  # rows.each { |r| vectors << Linalg::Vector.new(r) }
  #
  # mat = Linalg::Matrix.new(vectors)
  # mat # => [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  # ```
  #
  # An `ArgumentError` is raised if the given vectors have different sizes.
  def initialize(@elements : Array(Linalg::Vector(T)))
    {% raise "T must be an integer or a float" unless T < Number::Primitive %}
    @rows = @elements.size
    @columns = @elements[0].size 

    @elements.each do |elem|
      if elem.size != @columns
        raise ArgumentError.new("vectors must have the same size")
      end
    end
  end

  # Returns the number of rows in the matrix.
  #
  # NOTE: Same as `Linalg::Matrix#size`.
  getter rows : Int32

  # Returns the number of columns in the matrix.
  getter columns : Int32

  # Returns the element at the given *index*.
  #
  # ```
  # mat = Linalg::Matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
  # mat[2] # => [7, 8, 9]
  # ```
  def [](index : Int)
    @elements[index]
  end

  # Returns the element at the given position (row, col).
  #
  # ```
  # mat = Linalg::Matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
  # mat[1, 0] # => 4
  # ```
  def [](row : Int, col : Int)
    @elements[row][col]
  end

  # Sets the given *value* at the given position (row, col).
  #
  # ```
  # mat = Linalg::Matrix.new([[1, 0, 0], [0, 0, 0], [0, 0, 1]])
  # mat[1, 1] = 1
  # mat # => [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
  # ```
  def []=(row : Int, col : Int, value : T)
    @elements[row][col] = value
  end

  # Append. Converts the given array into a `Linalg::Vector` and appends it to `self`.
  #
  # ```
  # mat = Linalg::Matrix(Int32).new
  # mat << [1, 2, 3]
  # mat # => [1, 2, 3]
  # ```
  #
  # An `ArgumentError` is raised if the given array doesn't have the same
  # size as the vectors already in the matrix.
  def <<(value : Array(T))
    if !self.empty? && value.size != self.columns
      raise ArgumentError.new("expected an array of size #{self.columns}")
    end

    @elements << Linalg::Vector.new(value)

    if @rows == 0
      @columns = value.size
    end
    
    @rows += 1
  end

  # Appends the given vector to `self`.
  #
  # ```
  # mat = Linalg::Matrix(Int32).new
  # mat << Linalg::Vector.new([1, 2, 3])
  # mat # => [1, 2, 3]
  # ```
  #
  # An `ArgumentError` is raised if the given vector doesn't have the same
  # size as the vectors already in the matrix.
  def <<(value : Linalg::Vector(T))
    if !self.empty? && value.size != self.columns
      raise ArgumentError.new("expected a vector of size #{self.columns}")
    end

    @elements << value

    if @rows == 0
      @columns = value.size
    end
    
    @rows += 1
  end

  # Scales all the vectors in `self` by the given *scalar* and return a new `Linalg::Matrix`.
  #
  # ```
  # mat = Linalg::Matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
  # scaled_mat = mat * 2.0
  # scaled_mat # => [[2.0, 4.0, 6.0], [8.0, 10.0, 12.0], [14.0, 16.0, 18.0]]
  # ```
  def *(scalar : U) forall U
    {% raise "U must be an integer or a float" unless U < Number::Primitive %}
    mat = generate_matrix(T, U)

    @elements.each { |r| mat << r * scalar }

    return mat
  end

  # Matrix-vector multiplication
  #
  # ```
  # vec = Linalg::Vector.new([2.0, 3.0, 4.0])
  # mat = Linalg::Matrix.new([[5, 2, 6], [7, 2, 5], [1, 4, 2]])
  # mat * vec # => [40.0, 40.0, 22.0]
  # ```
  def *(other : Linalg::Vector(U)) forall U
    if other.size != self.columns
      raise ArgumentError.new("expected vector of size #{self.columns}")
    end
    
    vec = generate_vector(T, U)

    @elements.each do |row|
      sum = 0
      {% if T < Float || U < Float %}
        sum = 0.0
      {% end %}
      row.each_with_index do |elem, j|
        sum += elem * other[j]
      end
      vec << sum
    end

    return vec
  end

  # Returns the product of `self` and *other*.
  # If `self` is a m x n matrix and *other* is a n x p matrix then the product
  # will be a m x p matrix.
  #
  # ```
  # mat1 = Linalg::Matrix.new([[2, 1, 4], [-1, 0, 3]])
  # mat2 = Linalg::Matrix.new([[1, 6], [5, 1], [2, -2]])
  # product = mat1.product(mat2)
  # product # => [[15, 5], [5, -12]]
  # ```
  #
  # NOTE: Same as `Linalg::Matrix#product`
  def *(other : Linalg::Matrix)
    return self.product(other)
  end

  # Matrix addition. Adds `self` and *other* together and returns a new `Linalg::Matrix`.
  #
  # ```
  # mat1 = Linalg::Matrix.new([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]])
  # mat2 = Linalg::Matrix.new([[4, -1, 6], [2, 9, -3], [-4, 5, 1]])
  #
  # mat3 = mat1 + mat2
  # mat3 # => [[5.0, 1.0, 9.0], [6.0, 14.0, 3.0], [3.0, 13.0, 10.0]]
  # ```
  def +(other : Linalg::Matrix(U)) forall U
    if self.rows != other.rows || self.columns != other.columns
      raise ArgumentError.new("cannot perform matrix addition of matrices with different dimensions")
    end

    mat = generate_matrix(T, U)

    @elements.each_with_index do |row, i|
      mat << row + other[i]
    end

    return mat
  end

  # Matrix subtraction. Subtracts *other* from `self` and returns a new `Linalg::Matrix`.
  #
  # ```
  # mat1 = Linalg::Matrix.new([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]])
  # mat2 = Linalg::Matrix.new([[4, -1, 6], [2, 9, -3], [-4, 5, 1]])
  #
  # mat3 = mat1 - mat2
  # mat3 # => [[-3.0, 3.0, -3.0], [2.0, -4.0, 9.0], [11.0, 3.0, 8.0]]
  # ```
  def -(other : Linalg::Matrix(U)) forall U
    if self.rows != other.rows || self.columns != other.columns
      raise ArgumentError.new("cannot perform matrix subtraction of matrices with different dimensions")
    end

    mat = generate_matrix(T, U)

    @elements.each_with_index do |row, i|
      mat << row - other[i]
    end

    return mat
  end

  # Iterates over the collection, yielding the elements.
  def each(&block : Linalg::Vector(T) -> _)
    @elements.each { |e| yield e }
  end

  # Iterates over the collection, yielding both the elements and their index.
  #
  # See `Enumerable#each_with_index` for more details.
  def each_with_index(offset = 0)
    @elements.each_with_index offset do |element, i|
      yield element, i
    end
  end

  # Returns `true` if `self` is empty, `false` otherwise.
  def empty?
    @elements.empty?
  end

  # Returns the product of `self` and *other*.
  # If `self` is a m x n matrix and *other* is a n x p matrix then the product
  # will be a m x p matrix.
  #
  # ```
  # mat1 = Linalg::Matrix.new([[2, 1, 4], [-1, 0, 3]])
  # mat2 = Linalg::Matrix.new([[1, 6], [5, 1], [2, -2]])
  # product = mat1.product(mat2)
  # product # => [[15, 5], [5, -12]]
  # ```
  def product(other : Linalg::Matrix(U)) forall U
    if self.columns != other.rows
      raise ArgumentError.new("expected m x n * n x p matrices")
    end

    mat = generate_matrix(T, U)

    @elements.each do |row|
      row_dots = generate_vector(T, U)

      col = 0
      other.columns.times do
        vec = generate_vector(T, U)

        other.each do |other_row|
          vec << other_row[col]
        end

        row_dots << row * vec
        col += 1
      end

      mat << row_dots
    end

    return mat
  end

  # Returns the number of elements in the vector.
  #
  # NOTE: Same as `Linalg::Matrix#rows`.
  def size
    @elements.size
  end

  # Transposes the rows and columns of `self`.
  #
  # ```
  # mat = Linalg::Matrix.new([[1, 2], [3, 4], [5, 6]])
  # mat.transpose # => [[1, 3, 5], [2, 4, 6]]
  # mat # => [[1, 2], [3, 4], [5, 6]]
  # ```
  def transpose
    return typeof(self).new if self.empty?

    mat = typeof(self).new

    i = 0
    self.columns.times do
      vec = Linalg::Vector(T).new

      self.each { |r| vec << r[i] }

      i += 1
      mat << vec
    end

    return mat
  end

  def to_s(io : IO) : Nil
    io << "["
    @elements.each_with_index do |vec, i|
      io << vec
      if i != self.rows - 1
        io << ", "
      end
    end
    io << "]"
  end
end