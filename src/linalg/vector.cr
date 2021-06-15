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
end