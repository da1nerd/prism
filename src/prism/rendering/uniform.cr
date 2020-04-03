module Prism::Uniform
  # This may be deprecated soon
  # Registers a set of uniforms
  # These uniforms can be accessed by `self.uniform_{{name}}`
  # or by `get_uniform("{{name}}")`
  # NOTE: you should follow proper crystal formatting and make the uniform name snake_case.
  macro register_uniforms(uniforms)
    {% for uniform in uniforms %}
      @uniform_{{uniform[:name]}} : {{uniform[:type]}} = {{uniform[:default]}}
      property uniform_{{uniform[:name]}}
    {% end %}

    # Retrieves a uniform value by name
    def get_uniform(name : String)
      {% for uniform in uniforms %}
        if name == "{{uniform[:name]}}"
          return @uniform_{{uniform[:name]}}
        end
      {% end %}
    end
  end

  # TODO: all of the below should eventually go into the Shader namespace.
  annotation Field
  end

  # The `Prism::Uniform::Serializable` module automatically generates methods for Uniform serialization when included.
  module Serializable
    annotation Options
    end

    # The struct option will override the struct type for all fields in the object.
    # the field key is the key in the glsl code.
    # if the global struct option is not used you can specifiy structs granularly on each field.
    def to_uniform
      {% begin %}
        {% options = @type.annotation(::Prism::Uniform::Serializable::Options) %}
        {% global_struct_name = options && options[:struct] %}
        {% properties = {} of Nil => Nil %}
        {% types = [] of Nil %}
        # TODO: support collecting from methods as well
        {% for ivar in @type.instance_vars %}
          {% ann = ivar.annotation(::Prism::Uniform::Field) %}
          {% if ann && !ann[:ignore] && ann[:key] %}
            {%
              types << ivar.type
            %}
            {%
              properties[ivar.id] = {
                type:         ivar.type,
                serializable: ::Prism::Uniform::Serializable.includers.any? { |t| t == ivar.type },
                key:          ((ann && ann[:key]) || ivar).id.stringify,
                struct:       (ann && ann[:struct]) ? ann[:struct].id.stringify : false,
              }
            %}
          {% end %}
        {% end %}

        uniforms = {} of String => ({% for type, index in types %}{{type}} {% if index < types.size - 1 %} | {% end %}{% end %})

        {% for name, value in properties %}
          _{{name}} = @{{name}}
          unless _{{name}}.nil?
            {% struct_name = global_struct_name ? global_struct_name : value[:struct] %}
            {% uniform_key = struct_name ? struct_name + "." + value[:key] : value[:key] %}

            {% if value[:serializable] %}
              _{{name}}_uniforms = _{{name}}.to_uniform
              _{{name}}_uniforms.each do |k, v|
                uniforms[{{uniform_key}} + "." + k] = v
              end
            {% else %}
              uniforms[{{uniform_key}}] = _{{name}}
            {% end %}
          end
        {% end %}

        uniforms
      {% end %}
    end
  end
end
