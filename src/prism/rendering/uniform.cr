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

  annotation Field
  end

  # The `Prism::Uniform::Serializable` module automatically generates methods for Uniform serialization when included.
  module Serializable
    annotation Options
    end

    def to_uniform
      {% begin %}
        pp {{ @type.instance.annotation(::Prism::Uniform::Field).stringify }}
        {% options = @type.annotation(::Prism::Uniform::Serializable::Options) %}
        {% struct_name = options ? options[:struct] : @type.name  %}

        {% properties = {} of Nil => Nil %}
        {% for ivar in @type.instance_vars %}
          {% ann = ivar.annotation(::Prism::Uniform::Field) %}
          {% if ann && !ann[:ignore] && ann[:key] %}
            {%
              properties[ivar.id] = {
                type: ivar.type,
                key:  ((ann && ann[:key]) || ivar).id.stringify,
              }
            %}
          {% end %}
        {% end %}

        {% for name, value in properties %}
          _{{name}} = @{{name}}
          unless _{{name}}.nil?
            # puts "#{{{struct_name}}}.#{{{value[:key]}}}"
            # puts "key: " + {{value[:key]}}
            # puts "type: {{value[:type]}}"
            # puts "name: _{{name}}"
            # puts "value: #{_{{name}}}"
          end
        {% end %}
      {% end %}
    end
  end
end
