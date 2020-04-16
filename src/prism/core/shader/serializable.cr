include Prism::VMath

module Prism::Core::Shader
  # Placing this annotation on a method or instance variable will turn it into a uniform variable in a glsl program.
  annotation Field
  end

  # This exception is raised when a uniform has an invalid type.
  class UniformTypeException < Exception
  end

  alias UniformType = Int32 | Float32 | Vector3f | Matrix4f | Bool
  alias UniformMap = Hash(String, UniformType)

  # The `Prism::Shader::Serializable` module automatically generates methods for Uniform serialization when included.
  #
  # ## Example
  #
  # ```
  # class A
  #   include Shader::Serializable
  #
  #   @[Shader::Field]
  #   @a : String = "a"
  # end
  #
  # class B < A
  #   include Shader::Serializable
  #
  #   @[Shader::Field]
  #   @b : Float32 = 1
  # end
  #
  # my_b = B.new
  # my_b.to_uniform # => {"a" => "a", "b" => 1.0}
  # ```
  #
  # ### Usage
  #
  # Including `Shader::Serializable` will create a `#to_uniform` method on the current class.
  # By default, this method will serialize into a uniform object containing the value of every annotated instance variable, the keys being the instance variable name.
  # Supported primitives are (string, integer, float, Vector3f),
  # along with objects which include `Shader::Serializable`.
  # Union types are not supported.
  #
  # To change how individual instance variables are parsed and serialized, the annotation `Shader::Field`
  # can be placed on the instance variable. Annotating methods is also allowed.
  #
  # ```
  # class A
  #   include Shader::Serializable
  #
  #   @[Shader::Field(key: "attribute")]
  #   @a : String = "value"
  # end
  # ```
  #
  # `Shader::Field` properties:
  # * **key**: the value of the key in the uniform object (by default the name of the instance variable)
  #
  # ### Class annotation `Shader::Serializable::Options`
  #
  # supported properties:
  # * **name**: the name of the uniform struct variable in the glsl program.
  #
  # ```
  # @[Shader::Serializable::Options(name: "R_spotLight")]
  # class A
  #   include Shader::Serializable
  #   @[Shader::Field]
  #   @a : Int32 = 1
  # end
  #
  # c = A.new
  # c.to_uniform # => {"R_spotLight.a" => 1}
  # ```
  module Serializable
    annotation Options
    end

    private def raise_uniform_parse_error(klass, field, type, valid_types, field_location)
      message = <<-STRING
  Invalid uniform configuration!
  #{klass}.#{field} has an invalid uniform type '#{type}'. Try serialising '#{type}' or change '#{field}' to one of #{valid_types}.
    from #{field_location[:file]}:#{field_location[:line]}:#{field_location[:column]}.
  STRING
      raise UniformTypeException.new(message)
    end

    # Serializes the class to a Uniform object that can be consumed by the `Prism::Shader`.
    @[Raises]
    def to_uniform
      to_uniform(false)
    end

    # Allows manually injecting some uniform keys
    private def on_to_uniform : UniformMap | Nil
    end

    # Produces a map of uniform values
    protected def to_uniform(is_sub : Bool)
      {% begin %}
        {% options = @type.annotation(::Prism::Core::Shader::Serializable::Options) %}
        {% struct_name = options && options[:name] || false %}
        {% properties = {} of Nil => Nil %}

        {% for mdef in @type.methods %}
          {% ann = mdef.annotation(::Prism::Core::Shader::Field) %}
          {% if ann && !ann[:ignore] %}
            {%
              is_serializable = ::Prism::Core::Shader::Serializable.includers.any? { |t| t == mdef.return_type.id }
              # TODO: the comparison here is too strict.
              # t.name == mdef.return_type.id requires you to type out the full namespace or it will fail.
              is_valid = UniformType.union_types.any? { |t| t.name == mdef.return_type.id }
              properties[mdef.name] = {
                method:       true,
                type:         mdef.return_type,
                serializable: is_serializable,
                valid:        is_valid,
                key:          (ann && ann[:key]) ? ann[:key].id.stringify : mdef.name.stringify,
              }
            %}
            {% if !is_serializable && !is_valid %}
              raise_uniform_parse_error("{{@type.name}}", "{{mdef.name}}", "{{mdef.return_type}}", {{UniformType.union_types}}, {
                file: {{mdef.filename}},
                line: {{mdef.line_number}},
                column: {{mdef.column_number}}
              })
            {% end %}
          {% end %}
        {% end %}

        {% for ivar in @type.instance_vars %}
          {% ann = ivar.annotation(::Prism::Core::Shader::Field) %}
          {% if ann && !ann[:ignore] %}
            {%
              is_serializable = ::Prism::Core::Shader::Serializable.includers.any? { |t| t.name == ivar.type.name }
              is_valid = UniformType.union_types.any? { |t| t.name == ivar.type.name }
              properties[ivar.id] = {
                type:         ivar.type,
                serializable: is_serializable,
                valid:        is_valid,
                key:          ((ann && ann[:key]) || ivar).id.stringify,
              }
            %}
            {% if !is_serializable && !is_valid %}
              raise_uniform_parse_error("{{@type.name}}", "{{ivar.id}}", "{{ivar.type}}", {{UniformType.union_types}}, {
                file: {{ivar.filename}},
                line: {{ivar.line_number}},
                column: {{ivar.column_number}}
              })
            {% end %}
          {% end %}
        {% end %}

        uniforms = UniformMap.new

        {% for name, value in properties %}

          {% if value[:method] %}
            _{{name}} = {{name}}
          {% else %}
            _{{name}} = @{{name}}
          {% end %}

          unless _{{name}}.nil?
            {% uniform_key = struct_name ? struct_name + "." + value[:key] : value[:key] %}
            %struct_key = {{uniform_key}}
            %short_key = {{value[:key]}}
            %ukey = is_sub ? %short_key : %struct_key
            {% if value[:serializable] %}
              _{{name}}_uniforms = _{{name}}.to_uniform(true)
              _{{name}}_uniforms.each do |k, v|
                uniforms[%ukey + "." + k] = v
              end
            {% elsif value[:valid] %}
              uniforms[%ukey] = _{{name}}
            {% end %}
          end
        {% end %}

        # Add manual uniform definitions to the map
        _manual_uniforms = on_to_uniform
        if _manual_uniforms
          _manual_uniforms.each do |k, v|
            %ukey = is_sub && {{struct_name}} ? {{struct_name}}.to_s + "." + k : k
            uniforms[%ukey] = v
          end
        end
        uniforms
      {% end %}
    end
  end
end
