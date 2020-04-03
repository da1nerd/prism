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
    # If a field tries to use an unsupported type this will throw an error
    @[Raises]
    def to_uniform
      {% begin %}
        {% valid_types = [Int32, Float32, Prism::Vector3f, String] %}
        {% options = @type.annotation(::Prism::Uniform::Serializable::Options) %}
        {% global_struct_name = options && options[:struct] %}
        {% properties = {} of Nil => Nil %}
        # TODO: support collecting from methods as well
        {% for ivar in @type.instance_vars %}
          {% ann = ivar.annotation(::Prism::Uniform::Field) %}
          {% if ann && !ann[:ignore] && ann[:key] %}
            {%
              is_serializable = ::Prism::Uniform::Serializable.includers.any? { |t| t == ivar.type }
              is_valid = valid_types.any? { |t| t.name == ivar.type.name }
              properties[ivar.id] = {
                type:         ivar.type,
                serializable: is_serializable,
                valid:        is_valid,
                key:          ((ann && ann[:key]) || ivar).id.stringify,
                struct:       (ann && ann[:struct]) ? ann[:struct].id.stringify : false,
              }
            %}
            {% if !is_serializable && !is_valid %}
              raise Exception.new("#{{{@type.name}}}.{{ivar.id}} has an invalid uniform type '{{ivar.type}}'. Try serialising '{{ivar.type}}' or change #{{{@type.name}}}.{{ivar.id}} to one of {{valid_types}}.")
            {% end %}
          {% end %}
        {% end %}

        uniforms = {} of String => ({% for t, i in valid_types %}{{t}}{% if i < valid_types.size - 1 %} | {% end %}{% end %})
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
            {% elsif value[:valid] %}
              uniforms[{{uniform_key}}] = _{{name}}
            {% end %}
          end
        {% end %}

        uniforms
      {% end %}
    end
  end
end
