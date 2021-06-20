require "./spec_helper"

describe Linalg::Vector do
  describe "initialize" do
    it "should initialize a new empty vector of the given type" do
      vec = Linalg::Vector(Int32).new

      vec.size.should eq 0
    end

    it "should initialize a new vector containing the given elements" do
      tests = [
        {input: [1.0, 2.0, 3.0], expected: [1.0, 2.0, 3.0]},
        {input: [4.2, 94.7, 12.0], expected: [4.2, 94.7, 12.0]}
      ]

      tests.each do |test|
        vec = Linalg::Vector.new(test[:input])

        vec.each_with_index do |elem, i|
          elem.should eq test[:expected][i]
        end
      end
    end

    it "should initialize a new vector of the given size filled with zeros" do
      tests = [
        {size: 5, expected: 5},
        {size: 12, expected: 12},
        {size: 0, expected: 0}
      ]

      tests.each do |test|
        vec = Linalg::Vector(Int32).new(test[:size])

        vec.size.should eq test[:expected]
        vec.each { |e| e.should eq 0 }
      end
    end

    it "should raise an ArgumentError if size is less than 0" do
      expect_raises(ArgumentError) do
        Linalg::Vector(Int32).new(-1)
      end
    end
  end

  describe "[](index)" do
    it "should return the element at the given index" do
      vec = Linalg::Vector.new([4, 1, 52, 12, 92, 3, 8])
      tests = [
        {index: 2, expected: 52},
        {index: -1, expected: 8},
        {index: 0, expected: 4},
      ]

      tests.each do |test|
        vec[test[:index]].should eq test[:expected]
      end
    end
  end

  describe "[]=(index, value)" do
    it "should set the given value at the given index" do
      tests = [
        {index: 2, value: 52, expected: 52},
        {index: -1, value: 8, expected: 8},
        {index: 0, value: 4, expected: 4},
      ]

      tests.each do |test|
        vec = Linalg::Vector(Int32).new(5)
        vec[test[:index]] = test[:value]

        vec[test[:index]].should eq test[:expected]
      end
    end
  end

  describe "<<(value)" do
    it "should append a new element to the vector" do
      tests = [
        {items: [1, 2, 3], expected_items: [1, 2, 3], expected_size: 3},
        {items: [34, 1], expected_items: [34, 1], expected_size: 2},
        {items: [] of Int32, expected_items: [] of Int32, expected_size: 0}
      ]

      tests.each do |test|
        vec = Linalg::Vector(Int32).new

        test[:items].each { |i| vec << i }

        vec.size.should eq test[:expected_size]
        vec.each_with_index do |elem, i|
          elem.should eq test[:expected_items][i]
        end
      end
    end
  end

  describe "==(other)" do
    it "should return if self and other are equal or not" do
      tests = [
        {vec_input: [1, 2, 3], other_input: [1, 2, 3], expected: true},
        {vec_input: [1, 2, 3], other_input: [1, 2], expected: false},
        {vec_input: [1, 2], other_input: [1, 2, 3], expected: false},
        {vec_input: [] of Int32, other_input: [] of Int32, expected: true}
      ]

      tests.each do |test|
        vec = Linalg::Vector.new(test[:vec_input])
        other = Linalg::Vector.new(test[:other_input])

        (vec == other).should eq test[:expected]
      end
    end
  end

  describe "+(other : Vector)" do
    it "should add two vectors" do
      tests = [
        {vec_input: [2, -4, 7], other: [5, 3, 0], expected: [7, -1, 7]},
        {vec_input: [1, 2, 3], other: [4, 5, 6], expected: [5, 7, 9]},
        {vec_input: [12, 9, -1], other: [-8, 0, 1], expected: [4, 9, 0]},
      ]

      tests.each do |test|
        vec = Linalg::Vector.new(test[:vec_input])
        other = Linalg::Vector.new(test[:other])

        sum_vec = vec + other

        sum_vec.each_with_index do |elem, i|
          elem.should eq test[:expected][i]
        end
      end
    end

    it "should be able to add vector of ints and vector of floats together" do
      vec_int = Linalg::Vector(Int32).new([1, 2, 3])
      vec_float = Linalg::Vector(Float64).new([1.2, 2.3, 3.4])

      expected = Linalg::Vector(Float64).new([2.2, 4.3, 6.4])
      actual = vec_int + vec_float

      actual.each_with_index do |elem, i|
        elem.should eq expected[i]
      end
    end

    it "should raise an ArgumentError if the vectors are different sizes" do
      vec1 = Linalg::Vector.new([1, 2, 3])
      vec2 = Linalg::Vector.new([1, 2, 3, 4])

      expect_raises(ArgumentError) do
        vec1 + vec2
      end
    end
  end

  describe "-(other : Vector)" do
    it "should subtract two vectors" do
      tests = [
        {vec_input: [2, -4, 7], other: [5, 3, 0], expected: [-3, -7, 7]},
        {vec_input: [1, 2, 3], other: [4, 5, 6], expected: [-3, -3, -3]},
        {vec_input: [12, 9, -1], other: [-8, 0, 1], expected: [20, 9, -2]},
      ]

      tests.each do |test|
        vec = Linalg::Vector.new(test[:vec_input])
        other = Linalg::Vector.new(test[:other])

        sub_vec = vec - other

        sub_vec.each_with_index do |elem, i|
          elem.should eq test[:expected][i]
        end
      end
    end

    it "should be able to subtract a vector of floats from a vector of ints" do
      vec_int = Linalg::Vector(Int32).new([2, 3, 4])
      vec_float = Linalg::Vector(Float64).new([1.2, 2.3, 3.4])

      expected = Linalg::Vector(Float64).new([0.8, 0.7, 0.6])
      actual = vec_int - vec_float

      actual.each_with_index do |elem, i|
        elem.round(1).should eq expected[i]
      end
    end

    it "should raise an ArgumentError if the vectors are different sizes" do
      vec1 = Linalg::Vector.new([1, 2, 3])
      vec2 = Linalg::Vector.new([1, 2, 3, 4])

      expect_raises(ArgumentError) do
        vec1 - vec2
      end
    end
  end

  describe "*(scalar)" do
    it "should scale a vector by the given scalar" do
      tests = [
        {input: [5, 3, 0], scalar: 5.0, expected: [25, 15, 0]},
        {input: [1, 2, 3], scalar: 1.2, expected: [1.2, 2.4, 3.6]},
        {input: [12, 9, -1], scalar: -1.0, expected: [-12, -9, 1]},
      ]

      tests.each do |test|
        vec = Linalg::Vector.new(test[:input])

        scaled_vec = vec * test[:scalar]

        scaled_vec.each_with_index do |elem, i|
          # .round is required for the test to pass because
          # 3 * 1.2 == 3.5999999999999996
          elem.round(1).should eq test[:expected][i]
        end
      end
    end
  end

  describe "*(dot)" do
    it "should return the product" do
      vec1 = Linalg::Vector.new([-3.0, 7.0, 9.0])
      vec2 = Linalg::Vector.new([2, 0, 10])

      expected = 84
      actual = vec1.dot(vec2)

      actual.should eq expected
    end

    it "should raise an ArgumentError if the vectors are not the same size" do
      vec1 = Linalg::Vector.new([1, 2, 3])
      vec2 = Linalg::Vector.new([1, 2])

      expect_raises(ArgumentError) do
        vec1.dot(vec2)
      end
    end
  end

  describe "dot" do
    it "should return the product" do
      vec1 = Linalg::Vector.new([-3.0, 7.0, 9.0])
      vec2 = Linalg::Vector.new([2, 0, 10])

      expected = 84
      actual = vec1.dot(vec2)

      actual.should eq expected
    end

    it "should raise an ArgumentError if the vectors are not the same size" do
      vec1 = Linalg::Vector.new([1, 2, 3])
      vec2 = Linalg::Vector.new([1, 2])

      expect_raises(ArgumentError) do
        vec1.dot(vec2)
      end
    end
  end

  describe "*(other : Matrix)" do
    it "should perform vector-matrix multiplication" do
      vec = Linalg::Vector.new([2.0, 3.0, 4.0])
      mat = Linalg::Matrix.new([[5, 2, 6], [7, 2, 5], [1, 4, 2]])

      expected = [35.0, 26.0, 35.0]
      actual = vec * mat

      actual.each_with_index do |elem, i|
        elem.should eq expected[i]
      end
    end

    it "should raise an ArgumentError if matrix has fewer rows than vector.size" do
      vec = Linalg::Vector.new([2.0, 3.0, 4.0])
      mat = Linalg::Matrix.new([[5, 6], [7, 5]])

      expect_raises(ArgumentError) do
        vec * mat
      end
    end
  end

  describe "each" do
    it "should yield each element" do
      tests = [
        {input: [4, 1, 3, 52, 12], expected: [4, 1, 3, 52, 12]},
        {input: [0, 0, 0], expected: [0, 0, 0]},
        {input: [67, 23, 5, 573, 1], expected: [67, 23, 5, 573, 1]}
      ]

      tests.each do |test|
        vec = Linalg::Vector.new(test[:input])
        index = 0

        vec.each do |elem|
          elem.should eq test[:expected][index]
          index += 1
        end
      end
    end
  end

  describe "each_with_index" do
    it "should yield the elements and their index" do
      tests = [
        {input: [4, 1, 3, 52, 12], expected: [4, 1, 3, 52, 12]},
        {input: [0, 0, 0], expected: [0, 0, 0]},
        {input: [67, 23, 5, 573, 1], expected: [67, 23, 5, 573, 1]}
      ]

      tests.each do |test|
        vec = Linalg::Vector.new(test[:input])
        index = 0

        vec.each_with_index do |elem, i|
          i.should eq index
          elem.should eq test[:expected][i]
          index += 1
        end
      end
    end
  end

  describe "empty?" do
    it "should return true if vector is empty" do
      vec = Linalg::Vector(Int32).new

      vec.empty?.should be_true
    end

    it "should return false if vector is not empty" do
      vec = Linalg::Vector.new([1, 2, 3])

      vec.empty?.should be_false
    end
  end

  describe "size" do
    it "should return the number of elements in the vector" do
      vec = Linalg::Vector(Int32).new(14)

      vec.size.should eq 14
    end
  end
end