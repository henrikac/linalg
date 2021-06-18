class Linalg::Vector(T)
  # Creates a new empty `Vector`.
  #
  # ```
  # vec = Linalg::Vector(Int32).new
  # vec # => []
  # ```
  def initialize
    {% raise "T must be an integer or a float" unless T < Number::Primitive %}
    @elements = Array(T).new
  end

  # Creates a new `Vector` filled with the given *elements*.
  #
  # ```
  # vec = Linalg::Vector.new([1, 2, 3])
  # vec # => [1, 2, 3]
  # ```
  def initialize(@elements : Array(T))
    {% raise "T must be an integer or a float" unless T < Number::Primitive %}
  end

  # Creates a new `Vector` of given *size* filled with zeros.
  #
  # ```
  # vec = Linalg::Vector(Int32).new(3)
  # vec # => [0, 0, 0]
  # vec2 = Linalg::Vector(Float64).new(3)
  # vec2 # => [0.0, 0.0, 0.0]
  # ```
  def initialize(size : Int)
    {% raise "T must be an integer or a float" unless T < Number::Primitive %}
    if size < 0
      raise ArgumentError.new("Negative vector size: #{size}")
    end

    @elements = Array(T).new(size) { T.zero }
  end

  # Returns the element at the given *index*.
  def [](index : Int)
    @elements[index]
  end

  # Sets the given *value* at the given *index*.
  def []=(index : Int, value : T)
    @elements[index] = value
  end

  # Appends the given *value* to the end of the vector.
  def <<(value : T)
    @elements << value
  end

  # Returns `true` if each element in `self` is equal to each
  # corresponding element in *other*.
  def ==(other : Linalg::Vector)
    return false if self.size != other.size

    self.each_with_index do |elem, i|
      return false if elem != other[i]
    end
    return true
  end

  # Scaling. Scales `self` by the given *scalar* and returns a new `Linalg::Vector`.
  #
  # ```
  # vec = Linalg::Vector.new([1, 2, 3])
  # scalar = 2
  #
  # scaled_vec = vec * scalar
  # scaled_vec # => [2, 4, 6]
  # ```
  def *(scalar : U) forall U
    {% raise "U must be an integer or a float" unless U < Number::Primitive %}

    vec = generate_vector(T, U)
    self.each do |elem|
      vec << elem * scalar
    end
    return vec
  end

  # Vector addition. Adds `self` and *other* together and returns a new `Linalg::Vector`.
  #
  # ```
  # vec1 = Linalg::Vector.new([1, 2, 3])
  # vec2 = Linalg::Vector.new([2.1, 3.2, 4.3])
  #
  # vec3 = vec1 + vec2
  # vec3 # => [3.1, 5.2, 7.3]
  # ```
  def +(other : Linalg::Vector(U)) forall U
    if self.size != other.size
      raise ArgumentError.new("vectors must be same size")
    end

    vec = generate_vector(T, U)
    self.each_with_index do |elem, i|
      vec << elem + other[i]
    end
    return vec
  end

  # Vector subtraction. Subtracts *other* from `self` and returns a new `Linalg::Vector`.
  #
  # ```
  # vec1 = Linalg::Vector.new([2, 3, 4])
  # vec2 = Linalg::Vector.new([1, 2, 3])
  #
  # vec3 = vec1 - vec2
  # vec3 # => [1, 1, 1]
  # ```
  def -(other : Linalg::Vector(U)) forall U
    if self.size != other.size
      raise ArgumentError.new("vectors must be same size")
    end

    vec = generate_vector(T, U)
    self.each_with_index do |elem, i|
      vec << elem - other[i]
    end
    return vec
  end

  # Iterates over the collection, yielding the elements.
  def each(&block : T -> _)
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

  # Returns the number of elements in the vector.
  def size
    @elements.size
  end

  def to_s(io : IO) : Nil
    io << "["
    @elements.join(STDOUT, ", ") { |i, io| io << i }
    io << "]"
  end

  private def generate_vector(t1 : A.class, t2 : B.class) forall A, B
    vec = nil
    {% if !(A < Float) && B < Float %}
      vec = Linalg::Vector(B).new
    {% else %}
      vec = Linalg::Vector(A).new
    {% end %}
    return vec
  end
end