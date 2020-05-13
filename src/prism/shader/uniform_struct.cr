require "../maths"
include Prism::Maths

module Prism::Shader
  alias UniformType = Int32 | Float32 | Vector3f | Matrix4f | Bool
  alias UniformMap = Hash(String, UniformType)

  # Turns a class into a serializable uniform structure. Such a class can be used as a uniform in a shader `Program`.
  #
  # ## Example
  #
  # ```
  # class A
  #   include Shader::UniformStruct
  #
  #   @[Shader::Field]
  #   @a : String = "a"
  # end
  #
  # class B < A
  #   include Shader::UniformStruct
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
  # Including `Shader::UniformStruct` will create a `#to_uniform` method on the current class.
  # By default, this method will serialize into a uniform object containing the value of every annotated instance variable, the keys being the instance variable name.
  # Supported primitives are (string, integer, float, Vector3f),
  # along with objects which include `Shader::UniformStruct`.
  # Union types are not supported.
  #
  # To change how individual instance variables are parsed and serialized, the annotation `Shader::Field`
  # can be placed on the instance variable. Annotating methods is also allowed.
  #
  # ```
  # class A
  #   include Shader::UniformStruct
  #
  #   @[Shader::Field(name: "attribute")]
  #   @a : String = "value"
  # end
  # ```
  #
  # `Shader::Field` properties:
  # * **name**: the name of the property in the uniform object (by default the name of the instance variable)
  #
  # ### Class annotation `Shader::UniformStruct::Options`
  #
  # > DEPRECATED: the class anotation will be removed in a future version.
  #
  # supported properties:
  # * **name**: the name of the uniform struct variable in the glsl program.
  #
  # ```
  # @[Shader::UniformStruct::Options(name: "R_spotLight")]
  # class A
  #   include Shader::UniformStruct
  #   @[Shader::Field]
  #   @a : Int32 = 1
  # end
  #
  # c = A.new
  # c.to_uniform # => {"R_spotLight.a" => 1}
  # ```
  # TODO: Add the same macro syntax as the shader program so we can use `field "fieldName", SomeType`.
  #  We could still keep the annotation.
  module UniformStruct
    # DEPRECATED Support for setting the struct name will be removed in the future.
    annotation Options
    end

    # Transforms a method or instance variable into a field on the uniform struct.
    annotation Field
    end

    # Serializes the uniform struct into a map of uniform names and values.
    @[Raises]
    def to_uniform
      to_uniform(false)
    end

    # Allows manually injecting some uniform names
    private def on_to_uniform : UniformMap | Nil
    end

    # Produces a map of uniform values
    protected def to_uniform(is_sub : Bool)
      {% begin %}
        {% options = @type.annotation(::Prism::Shader::UniformStruct::Options) %}
        {% struct_name = options && options[:name] || false %}
        {% properties = {} of Nil => Nil %}

        {% for mdef in @type.methods %}
          {% ann = mdef.annotation(::Prism::Shader::UniformStruct::Field) %}
          {% if ann && !ann[:ignore] %}
            {%
              is_serializable = ::Prism::Shader::UniformStruct.includers.any? { |t| t == mdef.return_type.id }
              properties[mdef.name] = {
                method:       true,
                type:         mdef.return_type,
                serializable: is_serializable,
                name:         (ann && ann[:name]) ? ann[:name].id.stringify : mdef.name.stringify,
              }
            %}
          {% end %}
        {% end %}

        {% for ivar in @type.instance_vars %}
          {% ann = ivar.annotation(::Prism::Shader::UniformStruct::Field) %}
          {% if ann && !ann[:ignore] %}
            {%
              is_serializable = ::Prism::Shader::UniformStruct.includers.any? { |t| t.name == ivar.type.name }
              properties[ivar.id] = {
                type:         ivar.type,
                serializable: is_serializable,
                name:         ((ann && ann[:name]) || ivar).id.stringify,
              }
            %}
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
            {% uniform_key = struct_name ? struct_name + "." + value[:name] : value[:name] %}
            %struct_key = {{uniform_key}}
            %short_key = {{value[:name]}}
            %ukey = is_sub ? %short_key : %struct_key
            {% if value[:serializable] %}
              _{{name}}_uniforms = _{{name}}.to_uniform(true)
              _{{name}}_uniforms.each do |k, v|
                uniforms[%ukey + "." + k] = v
              end
            {% else %}
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
