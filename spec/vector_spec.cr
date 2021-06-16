require "./spec_helper"

describe Linalg::Vector do
  describe "initialize" do
    it "should initialize a new empty vector of the given type" do
      vec = Linalg::Vector(Int32).new

      vec.size.should eq 0
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