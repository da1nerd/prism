require "./serializable"

module Prism::Core::Shader
  extend self

  # Loads a shader program
  protected def read_shader_file(file_path : String, &file_reader : String -> String) : String
    input = file_reader.call file_path
    evaluate_includes input, &file_reader
  end

  # Searches for include statements and combines them with the *input*
  # An include statement looks like `#include "somefile.ext"`
  protected def evaluate_includes(input : String, &file_reader : String -> String) : String
    shader_source = ""

    input.each_line() do |line|
      include_match = line.scan(/\#include\s+["<]([^">]*)[>"]/)
      if include_match.size > 0
        shader_source += read_shader_file(include_match[0][1], &file_reader)
      else
        shader_source += line + "\n"
      end
    end

    return shader_source
  end

  # Represents a shader.
  # The terminology is a little inconsistent and needs some work.
  #
  # A `CompiledProgram` is a light wrapper around the shader program information. This holds information like the id, uniform names, etc.
  # This might be considered the heart of the `ShaderProgram` because well... it is.
  # The key purpose of the `CompiledProgram` is to prevent compiling the same program if it's used more than once.
  # Instead we will simply reuse the compiled program.
  #
  # This `ShaderProgram` contains all of the shader implementation.
  #
  # I probably need to rename these two classes
  class Program
    # A map of shader programs that have been created.
    # This allows us to re-use programs.
    @@programs = {} of String => CompiledProgram

    # The compiled program being used
    @resource : CompiledProgram

    # The name of shader file that was loaded.
    # This is used to clean up the programs map after garbage collection.
    @file_name : String

    # A map of registered uniform values
    @uniforms : UniformMap
    getter uniforms

    # Generates an inline uniform property.
    # Rather than namespacing `Shader::Serializable` uniforms with *name*, the uniforms are instead expanded so they can be accessed directly.
    # Properties added this way will be automatically bound to the compiled shader program when the shader is
    macro inline_uniform(name, type)
      # Sets the value of the {{name}} uniform.
      def {{name}}=(value : {{type}})
          if value.is_a?(Shader::Serializable)
              _{{name}}_uniforms = value.to_uniform(true)
              _{{name}}_uniforms.each do |k, v|
                  @uniforms[k] = v
              end
          else
              @uniforms["{{name}}"] = value
          end

          # TODO: bind textures
      end
    end

    # Generates a uniform property.
    # Properties added this way will be automatically bound to the compiled shader program when the shader is
    macro uniform(name, type)
        # Sets the value of the {{name}} uniform.
        def {{name}}=(value : {{type}})
            if value.is_a?(Shader::Serializable)
                _{{name}}_uniforms = value.to_uniform(true)
                _{{name}}_uniforms.each do |k, v|
                    @uniforms["{{name}}.#{k}"] = v
                end
            else
                @uniforms["{{name}}"] = value
            end

            # TODO: bind textures
        end
    end

    # Creates a new shader from *file_name*.
    #
    # The vertex and fragment shaders will be interpolated from *file_name*,
    # therefore *file_name* should be extension-less.
    #
    # Shader programs may include other files using the `#include "file.ext"` statement.
    # These includes are resolved by *shader_reader* which receives the name of the included file.
    #
    # > NOTE: *file_name* will be passed to *shader_reader* as well.
    #
    # ## Example
    #
    # ```
    # Shader.new "forward-point" do |path|
    #   File.read(File.join("my/shader/directory", path))
    #   # Ends up reading:
    #   # forward-point.vs
    #   # lighting.glh <- embeded into forward-point.vs
    #   # forward-point.fs
    # end
    # ```
    #
    # TODO: let this take in a path to the vertex shader and fragment shader for more flexibility.
    def initialize(@file_name : String, &shader_reader : String -> String)
      @uniforms = UniformMap.new
      if @@programs.has_key?(@file_name)
        # Re-use a compiled program so we don't need to compile a new one.
        @resource = @@programs[@file_name]
        @resource.add_reference
      else
        # create a new resource and register it with the list of active programs
        @resource = CompiledProgram.new
        @@programs[@file_name] = @resource

        # read the vertex and fragment shader files
        vertex_shader_text = Shader.read_shader_file("#{@file_name}.vs", &shader_reader)
        fragment_shader_text = Shader.read_shader_file("#{@file_name}.fs", &shader_reader)

        # load the shader code into OpenGL
        vertex_shader_id = load_shader(vertex_shader_text, LibGL::VERTEX_SHADER)
        fragment_shader_id = load_shader(fragment_shader_text, LibGL::FRAGMENT_SHADER)

        # attach the now-loaded shader code to the program.
        @resource.attach_shader(vertex_shader_id)
        @resource.attach_shader(fragment_shader_id)

        compile

        # searches for attributes in the vertex shader code and automatically binds them to the program
        automatically_bind_attributes(vertex_shader_text)

        # searches for uniforms in the shader code and automatically binds them to the program
        add_all_uniforms(vertex_shader_text)
        add_all_uniforms(fragment_shader_text)
      end
    end

    # An internal initalizer that uses `ShaderStorage` to load embedded shaders.
    # This makes it easy to use the embeded default shaders.
    protected def initialize(@file_name : String)
      initialize @file_name do |path|
        ShaderStorage.get(path).gets_to_end
      end
    end

    # garbage collection
    # When an instance of this class is garbage collected we will update the refernce counter.
    # When remove_reference returns true, there are no more objects using the resource so we delete
    # it from the pograms array which will eventually trigger it's own garbage collection.
    def finalize
      if @resource.remove_reference
        puts "Trashed shader #{@file_name}"
        @@programs.delete(@file_name)
      end
    end

    # Binds the program to OpenGL so it can run.
    # First we enable the program, then we bind values to all of the uniforms.
    # Finally, we enable all of the attributes.
    # TODO: rename this to bind
    def start(camera : Camera)
      LibGL.use_program(@resource.program)
      update_uniforms(camera)
      0.upto(@resource.num_attributes - 1) do |i|
        LibGL.enable_vertex_attrib_array(i)
      end
    end

    # Unbinds the program from OpenGL so it won't run.
    # TODO: rename this to unbind
    def stop
      0.upto(@resource.num_attributes - 1) do |i|
        LibGL.disable_vertex_attrib_array(i)
      end
      LibGL.use_program(0)
    end

    # Binds all of the uniform values to the program.
    private def update_uniforms(camera : Camera)
      # world_matrix = transform.get_transformation
      # mvp_matrix = camera.get_view_projection * world_matrix

      # maps the uniforms to the `UniformType`
      @resource.uniforms.each do |key, _|
        if @uniforms.has_key? key
          value = @uniforms[key]
          case value.class.name
          when "Int32"
            set_uniform(key, value.as(LibGL::Int))
          when "Bool"
            set_uniform(key, value.as(Bool))
          when "Float32"
            set_uniform(key, value.as(LibGL::Float))
          when "Prism::VMath::Vector3f"
            set_uniform(key, value.as(Vector3f))
          when "Prism::VMath::Matrix4f"
            set_uniform(key, value.as(Matrix4f))
          else
            raise Exception.new("Unsupported uniform type #{value.class}")
          end
        else
          puts "missing uniform #{key}"
        end
      end

      if @resource.uniform_names.size > 0
        0.upto(@resource.uniform_names.size - 1) do |i|
          uniform_name = @resource.uniform_names[i]
          uniform_type = @resource.uniform_types[i]
          # TODO: the below uniforms need to be configurable just like the lights are configurable.

          if uniform_name.starts_with?("T_")
            # transformations
            if uniform_name == "T_MVP" # model view projection
              # set_uniform(uniform_name, mvp_matrix)
            elsif uniform_name == "T_model"
              # TODO: T_model is now transformation_matrix in glsl
              # set_uniform(uniform_name, world_matrix)
            else
              puts "Error: #{uniform_name} is not a valid component of Transform"
              exit 1
            end
          elsif uniform_name.starts_with?("C_")
            # Camera
            if uniform_name == "C_eyePos"
              set_uniform(uniform_name, camera.transform.get_transformed_pos)
            else
              puts "Error: #{uniform_name} is not a valid component of Camera"
              exit 1
            end
          end
        end
      end
    end

    # Sets an integer uniform variable value
    private def set_uniform(name : String, value : LibGL::Int)
      LibGL.uniform_1i(@resource.uniforms[name], value)
    end

    # Sets a float uniform variable value
    private def set_uniform(name : String, value : LibGL::Float)
      LibGL.uniform_1f(@resource.uniforms[name], value)
    end

    # Sets a 3 dimensional float vector value to a uniform variable
    private def set_uniform(name : String, value : Vector3f)
      LibGL.uniform_3f(@resource.uniforms[name], value.x, value.y, value.z)
    end

    # Sets a 4 dimensional matrix float value to a uniform variable
    private def set_uniform(name : String, value : Matrix4f)
      LibGL.uniform_matrix_4fv(@resource.uniforms[name], 1, LibGL::TRUE, value.as_array)
    end

    # Sets a boolean uniform variable value.
    # Booleans are represented as floats in GLSL
    private def set_uniform(name : String, value : Bool)
      LibGL.uniform_1f(@resource.uniforms[name], value ? 1.0 : 0.0)
    end

    # compiles the shader
    private def compile
      LibGL.link_program(@resource.program)

      LibGL.get_program_iv(@resource.program, LibGL::LINK_STATUS, out link_status)
      if link_status == LibGL::FALSE
        LibGL.get_program_info_log(@resource.program, 1024, nil, out link_log)
        link_log_str = String.new(pointerof(link_log))
        link_error_code = LibGL.get_error
        puts "Error #{link_error_code}: Failed linking shader program: #{link_log_str}"
        exit 1
      end

      LibGL.validate_program(@resource.program)

      LibGL.get_program_iv(@resource.program, LibGL::VALIDATE_STATUS, out validate_status)
      if validate_status == LibGL::FALSE
        LibGL.get_program_info_log(@resource.program, 1024, nil, out validate_log)
        validate_log_str = String.new(pointerof(validate_log))
        validate_error_code = LibGL.get_error
        puts "Error #{validate_error_code}: Failed validating shader program: #{validate_log_str}"
        exit 1
      end

      # TODO: delete the shaders since they are linked into the program and we no longer need them
      # LibGL.delete_shader(shader)
    end

    # Parses the shader text for attribute delcarations and automatically adds them
    # This supports older versions of glsl as well as newer versions.
    #
    # This is handy because you don't need to worry about declaring the attributes yourself.
    # You only need to:
    # 1. define the attributes in your glsl code
    # 2. write the data to the buffer. `Mesh`
    # 3. position the pointers before drawing. `Mesh`
    #
    # TODO: It would be nice to eventually automate point 3 above.
    private def automatically_bind_attributes(shader_text : String)
      version = shader_text.scan(/#version\s+(\d+)/)[0][1].to_i
      keyword = version > 120 ? "in" : "attribute"
      start_location = shader_text.index(/^\b#{keyword}\b/m)
      attribute_number = 0

      while start = start_location
        end_location = shader_text.index(";", start).not_nil!
        uniform_line = shader_text[start..end_location]
        matches = uniform_line.scan(/^\b#{keyword}\b\s+([a-zA-Z0-9_]+)\s+([a-zA-Z0-9_]+)/)
        attribute_type = matches[0][1]
        attribute_name = matches[0][2]

        @resource.bind_attribute(attribute_name, attribute_number)
        attribute_number += 1

        start_location = shader_text.index(/\b#{keyword}\b/, end_location)
      end
    end

    # search for struct definitions in the shader text
    private def find_uniform_structs(shader_text : String) : Hash(String, GLSLStruct)
      keyword = "struct"
      start_location = shader_text.index(/\b#{keyword}\b/)
      structs = {} of String => GLSLStruct

      while start = start_location
        start_brace_location = shader_text.index("{", start).not_nil!
        end_brace_location = shader_text.index("}", start_brace_location).not_nil!

        # read struct name
        name_lines = shader_text[start..start_brace_location]
        name_matches = name_lines.scan(/\b#{keyword}\b\s+([a-zA-Z0-9_]+)\s+{/)
        struct_name = name_matches[0][1]

        # read struct properties
        property_lines = shader_text[start_brace_location..end_brace_location]
        property_matches = property_lines.scan(/\s*([a-zA-Z0-9_]+)\s+([a-zA-Z0-9_]+)/)
        properties = [] of GLSLProperty
        if property_matches.size > 0
          0.upto(property_matches.size - 1) do |i|
            property_type = property_matches[i][1]
            property_name = property_matches[i][2]
            properties.push(GLSLProperty.new(property_name, property_type))
          end
        else
          puts "Error: #{struct_name} at position #{start} has no properties"
          exit 1
        end

        structs[struct_name] = GLSLStruct.new(struct_name, properties)
        start_location = shader_text.index(/\b#{keyword}\b/, end_brace_location)
      end
      return structs
    end

    # Adds a uniform while expanding it's struct properties as needed
    private def register_uniform(uniform_name : String, uniform_type : String, structs : Hash(String, GLSLStruct))
      if structs.has_key?(uniform_type)
        properties = structs[uniform_type].properties
        0.upto(properties.size - 1) do |i|
          prop : GLSLProperty = properties[i]
          register_uniform("#{uniform_name}.#{prop.name}", prop.prop_type, structs)
        end
      else
        # add the final uniform
        uniform_location = LibGL.get_uniform_location(@resource.program, uniform_name)
        if uniform_location == -1
          uniform_error_code = LibGL.get_error
          raise Exception.new("Error #{uniform_error_code}: Could not find location for uniform '#{uniform_name}'.")
        end

        @resource.uniforms[uniform_name] = uniform_location
      end
    end

    # Parses the shader text for uniform declarations and automatically adds them
    private def add_all_uniforms(shader_text : String)
      structs = self.find_uniform_structs(shader_text)

      keyword = "uniform"
      start_location = shader_text.index(/\b#{keyword}\b/)
      while start = start_location
        end_location = shader_text.index(";", start).not_nil!
        uniform_line = shader_text[start..end_location]
        matches = uniform_line.scan(/\b#{keyword}\b\s+([a-zA-Z0-9_]+)\s+([a-zA-Z0-9_]+)/)
        uniform_type = matches[0][1]
        uniform_name = matches[0][2]

        @resource.uniform_names.push(uniform_name)
        @resource.uniform_types.push(uniform_type)
        self.register_uniform(uniform_name, uniform_type, structs)

        start_location = shader_text.index(/\b#{keyword}\b/, end_location)
      end
    end

    # Adds a shader program to OpenGL
    private def load_shader(text : String, type : LibGL::UInt) : UInt32
      shader_id = LibGL.create_shader(type)
      if shader_id == 0
        shader_error_code = LibGL.get_error
        puts "Error #{shader_error_code}: Shader creation failed. Could not find valid memory location when adding shader"
        exit 1
      end

      ptr = text.to_unsafe
      source = [ptr]
      LibGL.shader_source(shader_id, 1, source, Pointer(Int32).new(0))
      LibGL.compile_shader(shader_id)

      LibGL.get_shader_iv(shader_id, LibGL::COMPILE_STATUS, out compile_status)
      if compile_status == LibGL::FALSE
        LibGL.get_shader_info_log(shader_id, 2048, nil, out compile_log)
        compile_log_str = String.new(pointerof(compile_log))
        compile_error_code = LibGL.get_error
        puts "Error #{compile_error_code}: Failed compiling shader #{@file_name}\n'#{text}': #{compile_log_str}"
        exit 1
      end
      shader_id
    end
  end
end
