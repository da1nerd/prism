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

    def to_uniform
      {% begin %}
        # TODO: this should work, but for some reason it's not finding options.
        # See https://github.com/crystal-lang/crystal/blob/0.33.0/src/json/serialization.cr#L263
        # It would be nice if we could declare all of the fields to be in the same struct
        #{% options = @type.annotation(::Prism::Uniform::Serializable::Options) %}
        #{% glsl_struct_name = options && options[:struct] %}

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
                # TODO: it would be better to check if it is Uniform::Serializable
                serializable: ivar.type.has_method?("to_uniform"),
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
            {% if value[:serializable] %}
              puts {{value[:type]}} # debug
              # This line breaks when the macro is expanded
              # _{{name}}_uniforms = _{{name}}.to_uniform
              # TODO: expand uniforms into *uniforms* Hash
            {% else %}
              {% if value[:struct] %}
                uniforms["#{{{value[:struct]}}}.#{{{value[:key]}}}"] = _{{name}}
              {% else %}
                uniforms["#{{{value[:key]}}}"] = _{{name}}
              {% end %}
            {% end %}
          end
        {% end %}

        uniforms
      {% end %}
    end
  end
end
