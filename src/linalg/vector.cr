class Linalg::Vector(T)
  # Creates a new empty `Vector`.
  #
  # ```
  # vec = Linalg::Vector(Int32).new
  # vec # => []
  # ```
  def initialize
    {% raise "T must be a number" unless T < Number %}
    @elements = Array(T).new
  end

  # Creates a new `Vector` filled with the given *elements*.
  #
  # ```
  # vec = Linalg::Vector.new([1, 2, 3])
  # vec # => [1, 2, 3]
  # ```
  def initialize(@elements : Array(T))
    {% raise "T must be a number" unless T < Number %}
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
    {% raise "T must be a number" unless T < Number %}
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
end