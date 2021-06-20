require "../**"

def generate_vector(t1 : A.class, t2 : B.class) forall A, B
  vec = nil
  {% if !(A < Float) && B < Float %}
    vec = Linalg::Vector(B).new
  {% else %}
    vec = Linalg::Vector(A).new
  {% end %}
  return vec
end

def generate_matrix(t1 : A.class, t2 : B.class) forall A, B
  matrix = nil
  {% if !(A < Float) && B < Float %}
    matrix = Linalg::Matrix(B).new
  {% else %}
    matrix = Linalg::Matrix(A).new
  {% end %}
  return matrix
end