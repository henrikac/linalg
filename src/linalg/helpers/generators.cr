require "../**"

{% begin %}
  {% types = %w(Vector Matrix) %}
  {% for type in types %}
    macro generate_{{type.downcase.id}}(t1, t2)
      \{% if !(t1.resolve < Float) && t2.resolve < Float %}
        Linalg::{{type.id}}(\{{t2.resolve}}).new
      \{% else %}
        Linalg::{{type.id}}(\{{t1.resolve}}).new
      \{% end %}
    end
  {% end %}
{% end %}