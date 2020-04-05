module Prism
  class Shader
    # TODO: all of the below should eventually go into the Shader namespace.
    annotation Field
    end

    # This exception is raised when a uniform has an invalid type.
    class UniformTypeException < Exception
    end

    alias UniformMap = Hash(String, Int32 | Float32 | Prism::Vector3f | Prism::Matrix4f)

    # The `Prism::Uniform::Serializable` module automatically generates methods for Uniform serialization when included.
    #
    # ## Example
    #
    # ```
    # class A
    #   include Uniform::Serializable
    #
    #   @[Uniform::Field]
    #   @a : String = "a"
    # end
    #
    # class B < A
    #   include Uniform::Serializable
    #
    #   @[Uniform::Field]
    #   @b : Float32 = 1
    # end
    #
    # my_b = B.new
    # my_b.to_uniform # => {"a" => "a", "b" => 1.0}
    # ```
    #
    # ### Usage
    #
    # Including `Uniform::Serializable` will create a `#to_uniform` method on the current class.
    # By default, this method will serialize into a uniform object containing the value of every annotated instance variable, the keys being the instance variable name.
    # Supported primitives are (string, integer, float, Vector3f),
    # along with objects which include `Uniform::Serializable`.
    # Union types are not supported.
    #
    # To change how individual instance variables are parsed and serialized, the annotation `Uniform::Field`
    # can be placed on the instance variable. Annotating methods is also allowed.
    #
    # ```
    # class A
    #   include Uniform::Serializable
    #
    #   @[Uniform::Field(key: "attribute")]
    #   @a : String = "value"
    # end
    # ```
    #
    # `Uniform::Field` properties:
    # * **ignore**: if `true` skip this field in serialization.
    # * **key**: the value of the key in the uniform object (by default the name of the instance variable)
    # * **struct**: the name of the struct in the uniform object (by default keys are not in a struct)
    #
    # ### Class annotation `Uniform::Serializable::Options`
    #
    # supported properties:
    # * **struct**: if provided, this will prefix all field keys with the struct name. This overrides the struct property on all fields.
    #
    # ```
    # @[Uniform::Serializable::Options(struct: "BaseClass")]
    # class A
    #   include Uniform::Serializable
    #   @[Uniform::Field]
    #   @a : Int32 = 1
    # end
    #
    # c = A.new
    # c.to_uniform # => {"BaseClass.a" => 1}
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

      protected def to_uniform(is_sub : Bool)
        {% begin %}
        {% valid_types = [Int32, Float32, Prism::Vector3f, Prism::Matrix4f] %}
        {% options = @type.annotation(::Prism::Shader::Serializable::Options) %}
        {% global_struct_name = options && options[:struct] || false %}
        {% properties = {} of Nil => Nil %}

        {% for mdef in @type.methods %}
          {% ann = mdef.annotation(::Prism::Shader::Field) %}
          {% if ann && !ann[:ignore] %}
            {%
              is_serializable = ::Prism::Shader::Serializable.includers.any? { |t| t == mdef.return_type.id }
              is_valid = valid_types.any? { |t| t.name == mdef.return_type.id }
              properties[mdef.name] = {
                method:       true,
                type:         mdef.return_type,
                serializable: is_serializable,
                valid:        is_valid,
                key:          (ann && ann[:key]) ? ann[:key].id.stringify : mdef.name.stringify,
                struct:       (ann && ann[:struct]) ? ann[:struct].id.stringify : false,
              }
            %}
            {% if !is_serializable && !is_valid %}
              raise_uniform_parse_error("{{@type.name}}", "{{mdef.name}}", "{{mdef.return_type}}", {{valid_types}}, {
                file: {{mdef.filename}},
                line: {{mdef.line_number}},
                column: {{mdef.column_number}}
              })
            {% end %}
          {% end %}
        {% end %}

        {% for ivar in @type.instance_vars %}
          {% ann = ivar.annotation(::Prism::Shader::Field) %}
          {% if ann && !ann[:ignore] %}
            {%
              is_serializable = ::Prism::Shader::Serializable.includers.any? { |t| t.name == ivar.type.name }
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
              raise_uniform_parse_error("{{@type.name}}", "{{ivar.id}}", "{{ivar.type}}", {{valid_types}}, {
                file: {{ivar.filename}},
                line: {{ivar.line_number}},
                column: {{ivar.column_number}}
              })
            {% end %}
          {% end %}
        {% end %}

        uniforms = UniformMap.new # of String => ({% for t, i in valid_types %}{{t}}{% if i < valid_types.size - 1 %} | {% end %}{% end %})

        {% for name, value in properties %}

          {% if value[:method] %}
            _{{name}} = {{name}}
          {% else %}
            _{{name}} = @{{name}}
          {% end %}

          unless _{{name}}.nil?
            {% struct_name = global_struct_name ? global_struct_name : value[:struct] %}
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
            %ukey = is_sub && {{global_struct_name}} ? {{global_struct_name}}.to_s + "." + k : k
            uniforms[%ukey] = v
          end
        end
        uniforms
      {% end %}
      end
    end
  end
end
