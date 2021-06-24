require "./spec_helper"

describe Linalg::Matrix do
  describe "initialize" do
    it "should create an empty matrix" do
      mat = Linalg::Matrix(Float64).new

      mat.empty?.should be_true
    end

    it "should create a new matrix from a 2d array" do
      rows = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
      mat = Linalg::Matrix.new(rows)

      mat.rows.should eq 3
      mat.each_with_index do |row, i|
        row.each_with_index do |elem, j|
          elem.should eq rows[i][j]
        end
      end
    end

    it "should create a new matrix from an array of vectors" do
      rows = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
      vectors = Array(Linalg::Vector(Int32)).new

      rows.each { |r| vectors << Linalg::Vector.new(r) }

      mat = Linalg::Matrix.new(vectors)

      mat.rows.should eq 3
      mat.each_with_index do |row, i|
        row.each_with_index do |elem, j|
          elem.should eq rows[i][j]
        end
      end
    end

    it "should create an empty matrix if input is an empty array of vectors" do
      mat = Linalg::Matrix(Int32).new([] of Linalg::Vector(Int32))

      mat.rows.should eq 0
      mat.columns.should eq 0
    end

    it "should raise an ArgumentError if the elements in the 2d arrays are different sizes" do
      expect_raises(ArgumentError) do
        Linalg::Matrix.new([[1, 2, 3], [4, 5], [6, 7, 8]])
      end
    end

    it "should raise an ArgumentError if the vectors are different sizes" do
      vectors = Array(Linalg::Vector(Int32)).new
      vectors << Linalg::Vector.new([1, 2, 3])
      vectors << Linalg::Vector.new([4, 5, 6, 7])

      expect_raises(ArgumentError) do
        Linalg::Matrix.new(vectors)
      end
    end
  end

  describe "initialize zero matrix" do
    it "should create a new (rows x columns) zero matrix" do
      zero_mat = Linalg::Matrix(Float64).new(5, 4)

      zero_mat.rows.should eq 5
      zero_mat.columns.should eq 4
      zero_mat.each do |row|
        row.each do |elem|
          elem.should eq 0
        end
      end
    end

    it "should raise an ArgumentError if rows is less than 0" do
      expect_raises(ArgumentError) do
        Linalg::Matrix(Int32).new(-1, 2)
      end
    end
    
    it "should raise an ArgumentError if columns is less than 0" do
      expect_raises(ArgumentError) do
        Linalg::Matrix(Int32).new(2, -2)
      end
    end
  end

  describe "initialize identity matrix" do
    it "should create a new identity matrix" do
      identity_mat = Linalg::Matrix(Float64).new(3)

      identity_mat.rows.should eq 3
      identity_mat.columns.should eq 3
      identity_mat.each_with_index do |row, i|
        row.each_with_index do |elem, j|
          if j == i
            elem.should eq 1.0
          else
            elem.should eq 0.0
          end
        end
      end
    end

    it "should raise an ArgumentError if size is less than 1" do
      expect_raises(ArgumentError) do
        Linalg::Matrix(Int32).new(0)
      end
    end
  end

  describe "get_column" do
    it "should return the requested column" do
      mat = Linalg::Matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
      column = 2

      expected = [3, 6, 9]
      actual = mat.get_column(column)

      actual.empty?.should be_false
      actual.each_with_index do |elem, i|
        elem.should eq expected[i]
      end
    end

    it "should raise an IndexError if less than 0" do
      mat = Linalg::Matrix.new([[5, 1, 2, 4], [4, 2, 4, 3], [5, 2, 1, 5]])

      expect_raises(IndexError) do
        mat.get_column(-1)
      end
    end

    it "should raise an IndexError if greater than columns in the matrix" do
      mat = Linalg::Matrix.new([[5, 1, 2, 4], [4, 2, 4, 3], [5, 2, 1, 5]])

      expect_raises(IndexError) do
        mat.get_column(4)
      end
    end
  end

  describe "append_column" do
    it "should correctly append array to a non-empty matrix as a column" do
      mat = Linalg::Matrix.new([[1, 2], [4, 5], [7, 8]])
      column = [3, 6, 9]

      expected = Linalg::Matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]])

      mat.append_column(column)

      mat.rows.should eq expected.rows
      mat.columns.should eq expected.columns
      mat.should eq expected
    end

    it "should correctly append vector to a non-empty matrix as a column" do
      mat = Linalg::Matrix.new([[1, 2], [4, 5], [7, 8]])
      column = Linalg::Vector.new([3, 6, 9])

      expected = Linalg::Matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]])

      mat.append_column(column)

      mat.rows.should eq expected.rows
      mat.columns.should eq expected.columns
      mat.should eq expected
    end

    it "should correctly append array to an empty matrix as a column" do
      mat = Linalg::Matrix(Int32).new
      column = [3, 6, 9]

      expected = Linalg::Matrix.new([[3], [6], [9]])
      
      mat.append_column(column)

      mat.rows.should eq expected.rows
      mat.columns.should eq expected.columns
      mat.should eq expected
    end

    it "should correctly append vector to an empty matrix as a column" do
      mat = Linalg::Matrix(Int32).new
      column = Linalg::Vector.new([3, 6, 9])

      expected = Linalg::Matrix.new([[3], [6], [9]])

      mat.append_column(column)

      mat.rows.should eq expected.rows
      mat.columns.should eq expected.columns
      mat.should eq expected
    end

    it "should raise an ArgumentError if the size of the given column != the number of rows in the non-empty matrix" do
      mat = Linalg::Matrix.new([[1, 2], [4, 5], [7, 8]])

      expect_raises(ArgumentError) do
        mat.append_column([3, 6])
      end
    end
  end

  describe "*(scalar)" do
    it "should scale all vectors in the matrix by the given scalar" do
      mat = Linalg::Matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
      scalar = 2.0

      expected = [[2.0, 4.0, 6.0], [8.0, 10.0, 12.0], [14.0, 16.0, 18.0]]
      actual = mat * scalar

      actual.each_with_index do |row, i|
        row.each_with_index do |elem, j|
          elem.should eq expected[i][j]
        end
      end
    end

    it "(st)A = s(tA)" do
      tests = [
        {s: 2, t: 3},
        {s: 1, t: 2},
        {s: 4, t: 3},
        {s: -1, t: 1},
        {s: 3, t: -1}
      ]

      tests.each do |test|
        s = test[:s]
        t = test[:t]
        mat = Linalg::Matrix.new([[1, 2], [3, 4]])

        lhs = mat * (s * t)
        rhs = (mat * t) * s

        lhs.should eq rhs
      end
    end

    it "s(A + B) = sA + sB" do
      mata = Linalg::Matrix.new([[1, 2], [3, 4]])
      matb = Linalg::Matrix.new([[4, 3], [2, 1]])
      s = 1

      10.times do
        lhs = (mata + matb) * s
        rhs = mata * s + matb * s

        lhs.should eq rhs

        s += 1
      end
    end

    it "(s + t)A = sA + tA" do
      tests = [
        {s: 2, t: 3},
        {s: 1, t: 2},
        {s: 4, t: 3},
        {s: -1, t: 1},
        {s: 3, t: -1}
      ]

      tests.each do |test|
        s = test[:s]
        t = test[:t]
        mat = Linalg::Matrix.new([[1, 2], [3, 4]])

        lhs = mat * (s + t)
        rhs = mat * s + mat * t

        lhs.should eq rhs
      end
    end
  end

  describe "==(Matrix)" do
    mat1 = Linalg::Matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]])

    it "should return true if the matrices are equal" do
      mat2 = Linalg::Matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
      
      (mat1 == mat2).should be_true
    end

    it "should return false if the matrices have different dimensions" do
      tests = [
        {other: [[4, 5, 6], [7, 8, 9]]},
        {other: [[1, 3], [5, 6], [7, 8]]}
      ]

      tests.each do |test|
        mat2 = Linalg::Matrix.new(test[:other])

        (mat1 == mat2).should be_false
      end
    end

    it "should return false if the matrices have different values" do
      tests = [
        {other: [[1, 2, 3], [4, 5, 6], [7, 8, 8]]},
        {other: [[2, 1, 3], [4, 5, 6], [7, 8, 9]]},
        {other: [[1, 2, 3], [4, 5, 2], [7, 8, 9]]}
      ]

      tests.each do |test|
        mat2 = Linalg::Matrix.new(test[:other])

        (mat1 == mat2).should be_false
      end
    end
  end

  describe "*(other : Vector)" do
    it "should perform matrix-vector multiplication" do
      vec = Linalg::Vector.new([2.0, 3.0, 4.0])
      mat = Linalg::Matrix.new([[5, 2, 6], [7, 2, 5], [1, 4, 2]])

      expected = [40.0, 40.0, 22.0]
      actual = mat * vec

      actual.each_with_index do |elem, i|
        elem.should eq expected[i]
      end
    end

    it "should raise an ArgumentError if matrix has fewer columns than vector.size" do
      vec = Linalg::Vector.new([2.0, 3.0, 4.0])
      mat = Linalg::Matrix.new([[5, 6], [7, 5], [4, 2]])

      expect_raises(ArgumentError) do
        mat * vec
      end
    end
    
    it "A(u + v) = Au + Av" do
      tests = [
        {vecu: [1, 2, 3], vecv: [5, 2, 9]},
        {vecu: [5, 5, 5], vecv: [0, 0, 0]},
        {vecu: [4, -1, 8], vecv: [1, 1, 1]}
      ]

      tests.each do |test|
        vecu = Linalg::Vector.new(test[:vecu])
        vecv = Linalg::Vector.new(test[:vecv])
        mat = Linalg::Matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]])

        lhs = mat * (vecu + vecv)
        rhs = mat * vecu + mat * vecv

        lhs.should eq rhs
      end
    end

    it "A(cu) = c(Au) = (cA)u for every scalar c" do
      mat = Linalg::Matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
      vec = Linalg::Vector.new([5, -1, 2])
      scalar = -10

      20.times do
        lhs = mat * (vec * scalar)
        rhs = (mat * scalar) * vec

        lhs.should eq rhs

        scalar += 1
      end
    end

    it "(A + B)u = Au + Bu" do
      tests = [
        {mata: [[1, 2], [3, 4]], matb: [[2, 3], [1, 2]], vec: [1, 4]},
        {mata: [[6, -4], [0, 1]], matb: [[4, -1], [8, 0]], vec: [8, 3]},
        {mata: [[4, 3], [2, 1]], matb: [[2, 1], [3, 2]], vec: [4, -1]}
      ]

      tests.each do |test|
        mata = Linalg::Matrix.new(test[:mata])
        matb = Linalg::Matrix.new(test[:matb])
        vec = Linalg::Vector.new(test[:vec])

        lhs = (mata + matb) * vec
        rhs = mata * vec + matb * vec
      end
    end

    it "Ae_j = a_j for j = 1, 2..n, where e_j is the j th std vector in Rn" do
      tests = [
        {mat: [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10], [11, 12, 13, 14, 15]], n: 5},
        {mat: [[1, 2, 3], [4, 5, 6], [7, 8, 9]], n: 3}
      ]

      tests.each do |test|
        mat = Linalg::Matrix.new(test[:mat])
        
        i = 0
        mat.columns.times do
          std_vec = Linalg::Vector(Int32).new(test[:n])
          std_vec[i] = 1

          lhs = mat * std_vec
          rhs = mat.get_column(i)

          lhs.should eq rhs

          i += 1
        end
      end
    end

    it "A0 is the m x 1 zero vector" do
      test_matrices = [
        Linalg::Matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]]),
        Linalg::Matrix.new([[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12]]),
        Linalg::Matrix.new([[1, 2], [3, 4], [5, 6], [7, 8], [9, 10]])
      ]

      test_matrices.each do |test_matrix|
        zero_vec = Linalg::Vector(Int32).new(test_matrix.columns)

        lhs = test_matrix * zero_vec
        rhs = Linalg::Vector(Int32).new(test_matrix.rows)

        rhs.zero?.should be_true
        lhs.should eq rhs
      end
    end

    it "if 0 is the m x n zero matrix, then 0v is the m x 1 zero vector" do
      tests = [
        {vec: [1, 2, 3, 4, 5], rows: 5, cols: 5},
        {vec: [6, -1, 9], rows: 1, cols: 3},
        {vec: [-3, 0, 1, 3], rows: 8, cols: 4}
      ]

      tests.each do |test|
        vec = Linalg::Vector.new(test[:vec])
        zero_vec = Linalg::Matrix(Int32).new(test[:rows], test[:cols])

        lhs = zero_vec * vec
        rhs = Linalg::Vector(Int32).new(test[:rows])

        lhs.should eq rhs
      end
    end

    it "I_n * v = v" do
      tests = [
        {vec: [1, 2, 3, 4, 5], identity_size: 5},
        {vec: [6, -1, 9], identity_size: 3},
        {vec: [-3, 0, 1, 3], identity_size: 4}
      ]

      tests.each do |test|
        vec = Linalg::Vector.new(test[:vec])
        identity_mat = Linalg::Matrix(Int32).new(test[:identity_size])

        lhs = identity_mat * vec
        rhs = vec

        lhs.should eq rhs
      end
    end
  end

  describe "*(product)" do
    it "should compute the product of two matrices" do
      mat1 = Linalg::Matrix.new([[2, 1, 4], [-1, 0, 3]])
      mat2 = Linalg::Matrix.new([[1, 6], [5, 1], [2, -2]])

      expected = [[15, 5], [5, -12]]
      actual = mat1 * mat2

      actual.each_with_index do |row, i|
        row.each_with_index do |elem, j|
          elem.should eq expected[i][j]
        end
      end
    end

    it "should raise an ArgumentError if the matrices have invalid dimensions" do
      mat1 = Linalg::Matrix.new([[2, 1, 4], [-1, 0, 3]])
      mat2 = Linalg::Matrix.new([[5, 1, 1], [2, -2, 1]])

      expect_raises(ArgumentError) do
        mat1 * mat2
      end
    end
  end

  describe "+(other : Linalg::Matrix)" do
    it "should add two matrices" do
      mat1 = Linalg::Matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
      mat2 = Linalg::Matrix.new([[4, -1, 6], [2, 9, -3], [-4, 5, 1]])

      expected = [[5, 1, 9], [6, 14, 3], [3, 13, 10]]
      actual = mat1 + mat2

      actual.each_with_index do |row, i|
        row.each_with_index do |elem, j|
          elem.should eq expected[i][j]
        end
      end
    end

    it "should add two matrices of different types" do
      mat1 = Linalg::Matrix.new([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]])
      mat2 = Linalg::Matrix.new([[4, -1, 6], [2, 9, -3], [-4, 5, 1]])

      expected = [[5.0, 1.0, 9.0], [6.0, 14.0, 3.0], [3.0, 13.0, 10.0]]
      actual = mat1 + mat2

      typeof(actual).should eq Linalg::Matrix(Float64)
      actual.each_with_index do |row, i|
        row.each_with_index do |elem, j|
          elem.should eq expected[i][j]
        end
      end
    end

    it "should raise an ArgumentError if the matrices have different dimensions" do
      mat1 = Linalg::Matrix.new([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
      mat2 = Linalg::Matrix.new([[4, -1, 6], [2, 9, -3], [-4, 5, 1]])

      expect_raises(ArgumentError) do
        mat1 + mat2
      end
    end

    it "A + B = B + A" do
      tests = [
        {mata: [[1, 2], [3, 4]], matb: [[4, 2], [1, 2]]},
        {mata: [[5, 2], [9, 3]], matb: [[4, 0], [0, 3]]},
        {mata: [[8, 5], [6, 1]], matb: [[-1, 6], [2, -8]]}
      ]

      tests.each do |test|
        mata = Linalg::Matrix.new(test[:mata])
        matb = Linalg::Matrix.new(test[:matb])

        lhs = mata + matb
        rhs = matb + mata

        lhs.should eq rhs
      end
    end

    it "(A + B) + C = A + (B + C)" do
      tests = [
        {mata: [[1, 2], [3, 4]], matb: [[2, 3], [1, 2]], matc: [[4, 1], [1, 4]]},
        {mata: [[6, -4], [0, 1]], matb: [[4, -1], [8, 0]], matc: [[8, 3], [-5, 0]]},
        {mata: [[4, 3], [2, 1]], matb: [[2, 1], [3, 2]], matc: [[4, 1], [1, 4]]}
      ]

      tests.each do |test|
        mata = Linalg::Matrix.new(test[:mata])
        matb = Linalg::Matrix.new(test[:matb])
        matc = Linalg::Matrix.new(test[:matc])

        lhs = (mata + matb) + matc
        rhs = mata + (matb + matc)

        lhs.should eq rhs
      end
    end

    it "A + 0 = A" do
      tests = [
        {mat: [[1, 2, 3], [4, 5, 6]]},
        {mat: [[5, 2, 1, -4], [-3, -2, -9, 10]]},
        {mat: [[-3, 5, 9, 2], [1, 2, 3, 4], [-1, -1, -1, -1]]}
      ]

      tests.each do |test|
        mat = Linalg::Matrix.new(test[:mat])
        zero_mat = Linalg::Matrix(Int32).new(mat.rows, mat.columns)

        lhs = mat + zero_mat
        rhs = mat

        lhs.should eq rhs
      end
    end

    it "A + (-A) = 0" do
      tests = [
        {mat: [[1, 2, 3], [4, 5, 6]]},
        {mat: [[5, 2, 1, -4], [-3, -2, -9, 10]]},
        {mat: [[-3, 5, 9, 2], [1, 2, 3, 4], [-1, -1, -1, -1]]}
      ]

      tests.each do |test|
        mat = Linalg::Matrix.new(test[:mat])
        zero_mat = Linalg::Matrix(Int32).new(mat.rows, mat.columns)

        lhs = mat + (-mat)
        rhs = zero_mat

        lhs.should eq rhs
      end
    end
  end

  describe "-(other : Linalg::Matrix)" do
    it "should subtract two matrices" do
      mat1 = Linalg::Matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
      mat2 = Linalg::Matrix.new([[4, -1, 6], [2, 9, -3], [-4, 5, 1]])

      expected = [[-3, 3, -3], [2, -4, 9], [11, 3, 8]]
      actual = mat1 - mat2

      actual.each_with_index do |row, i|
        row.each_with_index do |elem, j|
          elem.should eq expected[i][j]
        end
      end
    end

    it "should subtract two matrices of different types" do
      mat1 = Linalg::Matrix.new([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]])
      mat2 = Linalg::Matrix.new([[4, -1, 6], [2, 9, -3], [-4, 5, 1]])

      expected = [[-3.0, 3.0, -3.0], [2.0, -4.0, 9.0], [11.0, 3.0, 8.0]]
      actual = mat1 - mat2

      typeof(actual).should eq Linalg::Matrix(Float64)
      actual.each_with_index do |row, i|
        row.each_with_index do |elem, j|
          elem.should eq expected[i][j]
        end
      end
    end

    it "should raise an ArgumentError if the matrices have different dimensions" do
      mat1 = Linalg::Matrix.new([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
      mat2 = Linalg::Matrix.new([[4, -1, 6], [2, 9, -3], [-4, 5, 1]])

      expect_raises(ArgumentError) do
        mat1 - mat2
      end
    end
  end

  describe "<<(value : Array)" do
    it "should convert given array into a vector and add it to the matrix" do
      arr = [7, 8, 9]
      mat = Linalg::Matrix.new([[1, 2, 3], [4, 5, 6]])

      mat << arr

      mat.size.should eq 3
      mat.rows.should eq 3
      typeof(mat[2]).should eq Linalg::Vector(Int32)
      mat[2].each_with_index do |elem, i|
        elem.should eq arr[i]
      end
    end

    it "should raise an ArgumentError if the size of the given array != matrix.columns" do
      mat = Linalg::Matrix.new([[1, 2, 3, 4], [5, 6, 7, 8]])

      expect_raises(ArgumentError) do
        mat << [1, 2, 3]
      end
    end
  end

  describe "<<(value : Linalg::Vector)" do
    it "should add the given vector to the matrix" do
      vec = Linalg::Vector.new([7, 8, 9])
      mat = Linalg::Matrix(Int32).new

      mat << vec

      mat.size.should eq 1
      mat.rows.should eq 1
      typeof(mat[0]).should eq Linalg::Vector(Int32)
      mat[0].each_with_index do |elem, i|
        elem.should eq vec[i]
      end
    end

    it "should raise an ArgumentError if the size of the given vector != matrix.columns" do
      mat = Linalg::Matrix.new([[1, 2, 3, 4], [5, 6, 7, 8]])

      expect_raises(ArgumentError) do
        mat << Linalg::Vector.new([1, 2, 3])
      end
    end
  end

  describe "[](index)" do
    it "should return the element at the given index" do
      rows = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
      mat = Linalg::Matrix.new(rows)

      expected = [4, 5, 6]
      actual = mat[1]

      actual.each_with_index do |elem, i|
        elem.should eq expected[i]
      end
    end
  end

  describe "[](row, col)" do
    it "should return the element at the given position" do
      rows = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
      mat = Linalg::Matrix.new(rows)

      tests = [
        {position: {1, 0}, expected: 4},
        {position: {0, 2}, expected: 3},
        {position: {2, 2}, expected: 9}
      ]

      tests.each do |test|
        row, col = test[:position]

        mat[row][col].should eq test[:expected]
      end
    end
  end

  describe "[]=(row, col, value)" do
    rows = [[1, 0, 0], [0, 0, 0], [0, 0, 1]]
    mat = Linalg::Matrix.new(rows)

    mat[1, 1] = 1
    expected = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]

    mat.each_with_index do |row, i|
      row.each_with_index do |elem, j|
        elem.should eq expected[i][j]
      end
    end
  end

  describe "product" do
    it "should compute the product of two matrices" do
      mat1 = Linalg::Matrix.new([[2, 1, 4], [-1, 0, 3]])
      mat2 = Linalg::Matrix.new([[1, 6], [5, 1], [2, -2]])

      expected = [[15, 5], [5, -12]]
      actual = mat1.product(mat2)

      actual.each_with_index do |row, i|
        row.each_with_index do |elem, j|
          elem.should eq expected[i][j]
        end
      end
    end

    it "should raise an ArgumentError if the matrices have invalid dimensions" do
      mat1 = Linalg::Matrix.new([[2, 1, 4], [-1, 0, 3]])
      mat2 = Linalg::Matrix.new([[5, 1, 1], [2, -2, 1]])

      expect_raises(ArgumentError) do
        mat1.product(mat2)
      end
    end
  end

  describe "transpose" do
    it "should return an empty matrix if transpose an empty matrix" do
      mat = Linalg::Matrix(Int32).new

      transposed_mat = mat.transpose

      typeof(transposed_mat).should eq Linalg::Matrix(Int32)
      transposed_mat.empty?.should be_true
    end

    it "should transpose the matrix" do
      tests = [
        {input: [[1, 2], [3, 4], [5, 6]], row_col: {2, 3}, expected: [[1, 3, 5], [2, 4, 6]]},
        {input: [[1, 2], [3, 4]], row_col: {2, 2}, expected: [[1, 3], [2, 4]]}
      ]

      tests.each do |test|
        mat = Linalg::Matrix.new(test[:input])

        expected = test[:expected]
        actual = mat.transpose

        actual.rows.should eq test[:row_col][0]
        actual.columns.should eq test[:row_col][1]
        actual.each_with_index do |row, i|
          row.each_with_index do |elem, j|
            elem.should eq expected[i][j]
          end
        end
      end
    end

    it "(A + B).transpose = A.transpose + B.transpose" do
      tests = [
        {mata: [[1, 2, 3], [4, 5, 6]], matb: [[4, 1, 2], [5, 4, 2]]},
        {mata: [[1, 2], [3, 4]], matb: [[5, 2], [4, 9]]},
        {mata: [[9, 4, 1], [52, 3, 5]], matb: [[5, 2, 9], [2, 1, 4]]}
      ]

      tests.each do |test|
        mata = Linalg::Matrix.new(test[:mata])
        matb = Linalg::Matrix.new(test[:matb])

        lhs = (mata + matb).transpose
        rhs = mata.transpose + matb.transpose

        lhs.should eq rhs
      end
    end

    it "(sA).transpose = sA.transpose" do
      tests = [
        {scalar: 2, mat: [[1, 2, 3], [4, 5, 6]]},
        {scalar: 3, mat: [[1, 2], [3, 4]]},
        {scalar: -1, mat: [[9, 4, 1], [52, 3, 5]]}
      ]

      tests.each do |test|
        scalar = test[:scalar]
        mat = Linalg::Matrix.new(test[:mat])

        lhs = (mat * scalar).transpose
        rhs = mat.transpose * scalar

        lhs.should eq rhs
      end
    end

    it "(A.transpose).transpose = A" do
      tests = [
        {mat: [[1, 2, 3], [4, 5, 6]]},
        {mat: [[1, 2], [3, 4]]},
        {mat: [[9, 4, 1], [52, 3, 5]]}
      ]

      tests.each do |test|
        mat = Linalg::Matrix.new(test[:mat])

        lhs = (mat.transpose).transpose
        rhs = mat

        lhs.should eq rhs
      end
    end
  end

  describe "zero?" do
    it "should return true if matrix is a zero matrix" do
      mat = Linalg::Matrix(Int32).new(3, 4)

      mat.zero?.should be_true
    end

    it "should return false if matrix is empty" do
      mat = Linalg::Matrix(Int32).new

      mat.zero?.should be_false
    end

    it "should return false if matrix is not a zero matrix" do
      mat = Linalg::Matrix(Int32).new(3)

      mat.zero?.should be_false
    end
  end

  describe "identity?" do
    it "should return true if matrix is an identity matrix" do
      mat = Linalg::Matrix(Int32).new(3)

      mat.identity?.should be_true
    end

    it "should return false if matrix is not an identity matrix" do
      mat = Linalg::Matrix(Int32).new(3, 4)

      mat.identity?.should be_false
    end
  end
end