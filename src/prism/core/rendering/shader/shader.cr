require "lib_gl"
require "../material"
require "../../transform"
require "./serializable"

module Prism::Core
  class Shader
    @@loaded_shaders = {} of String => ShaderResource
    @resource : ShaderResource
    @uniform_map : Shader::UniformMap
    @file_name : String

    # Creates a new shader from *file_name*.
    #
    # The vector and fragment shaders will be interpolated from *file_name*,
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
    #   # lighting.glh <- embeded into foward-point.fs
    # end
    # ```
    #
    def initialize(@file_name : String, &shader_reader : String -> String)
      @uniform_map = Shader::UniformMap.new
      if @@loaded_shaders.has_key?(@file_name)
        @resource = @@loaded_shaders[@file_name]
        @resource.add_reference
      else
        @resource = ShaderResource.new
        vertex_shader_text = Shader.load_shader_program("#{@file_name}.vs", &shader_reader)
        fragment_shader_text = Shader.load_shader_program("#{@file_name}.fs", &shader_reader)

        add_vertex_shader(vertex_shader_text)
        add_fragment_shader(fragment_shader_text)

        add_all_attributes(vertex_shader_text)

        compile

        add_all_uniforms(vertex_shader_text)
        add_all_uniforms(fragment_shader_text)

        @@loaded_shaders[@file_name] = @resource
      end
    end

    # An internal initalizer that uses `ShaderStorage` to load embedded shaders.
    # This allows using the embeded default shaders.
    protected def initialize(@file_name : String)
      initialize @file_name do |path|
        ShaderStorage.get(path).gets_to_end
      end
    end

    # garbage collection
    def finalize
      if @resource.remove_reference
        @@loaded_shaders.delete(@file_name)
      end
    end

    # Uses the shader
    def bind(@uniform_map : Shader::UniformMap, transform : Transform, material : Material, camera : Camera)
      LibGL.use_program(@resource.program)
      update_uniforms(transform, material, camera)
    end

    private def update_uniforms(transform : Transform, material : Material, camera : Camera)
      world_matrix = transform.get_transformation
      mvp_matrix = camera.get_view_projection * world_matrix
      material_uniforms = material.to_uniform

      # maps the uniforms to the `UniformType`
      @resource.uniforms.each do |key, _|
        if @uniform_map.has_key? key
          value = @uniform_map[key]
          case value.class.name
          when "Int32"
            set_uniform(key, value.as(LibGL::Int))
          when "Float32"
            set_uniform(key, value.as(LibGL::Float))
          when "Prism::VMath::Vector3f"
            set_uniform(key, value.as(Vector3f))
          when "Prism::VMath::Matrix4f"
            set_uniform(key, value.as(Matrix4f))
          else
            raise Exception.new("Unsupported uniform type #{value.class}")
          end
        elsif material_uniforms.has_key? key
          if material.has_texture? key
            material.bind_texture key
          end

          value = material_uniforms[key]
          case value.class.name
          when "Int32"
            set_uniform(key, value.as(LibGL::Int))
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
          # puts "missing uniform #{key}"
        end
      end

      if @resource.uniform_names.size > 0
        0.upto(@resource.uniform_names.size - 1) do |i|
          uniform_name = @resource.uniform_names[i]
          uniform_type = @resource.uniform_types[i]

          if uniform_name.starts_with?("T_")
            # transformations
            if uniform_name == "T_MVP"
              set_uniform(uniform_name, mvp_matrix)
            elsif uniform_name == "T_model"
              set_uniform(uniform_name, world_matrix)
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

    private def set_attrib_location(attribute : String, location : LibGL::Int)
      LibGL.bind_attrib_location(@resource.program, location, attribute)
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

    # Loads a shader program
    def self.load_shader_program(file_path : String, &file_reader : String -> String) : String
      input = file_reader.call file_path
      evaluate_includes input, &file_reader
    end

    # Searches for include statements and combines them with the *input*
    # An include statement looks like `#include "somefile.ext"`
    private def self.evaluate_includes(input : String, &file_reader : String -> String) : String
      shader_source = ""

      input.each_line() do |line|
        include_match = line.scan(/\#include\s+["<]([^">]*)[>"]/)
        if include_match.size > 0
          shader_source += load_shader_program(include_match[0][1], &file_reader)
        else
          shader_source += line + "\n"
        end
      end

      return shader_source
    end

    private def add_vertex_shader(text : String)
      add_program(text, LibGL::VERTEX_SHADER)
    end

    private def add_geometry_shader(text : String)
      add_program(text, LibGL::GEOMETRY_SHADER)
    end

    private def add_fragment_shader(text : String)
      add_program(text, LibGL::FRAGMENT_SHADER)
    end

    # Parses the shader text for attribute delcarations and automatically adds them
    private def add_all_attributes(shader_text : String)
      keyword = "attribute"
      start_location = shader_text.index(/\b#{keyword}\b/)
      attribute_number = 0
      while start = start_location
        end_location = shader_text.index(";", start).not_nil!
        uniform_line = shader_text[start..end_location]
        matches = uniform_line.scan(/\b#{keyword}\b\s+([a-zA-Z0-9_]+)\s+([a-zA-Z0-9_]+)/)
        attribute_type = matches[0][1]
        attribute_name = matches[0][2]

        set_attrib_location(attribute_name, attribute_number)
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
    private def add_uniform(uniform_name : String, uniform_type : String, structs : Hash(String, GLSLStruct))
      if structs.has_key?(uniform_type)
        properties = structs[uniform_type].properties
        0.upto(properties.size - 1) do |i|
          prop : GLSLProperty = properties[i]
          add_uniform("#{uniform_name}.#{prop.name}", prop.prop_type, structs)
        end
      else
        # add the final uniform
        uniform_location = LibGL.get_uniform_location(@resource.program, uniform_name)
        if uniform_location == -1
          uniform_error_code = LibGL.get_error
          puts "Error #{uniform_error_code}: Could not find location for uniform '#{uniform_name}'."
          exit 1
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
        self.add_uniform(uniform_name, uniform_type, structs)

        start_location = shader_text.index(/\b#{keyword}\b/, end_location)
      end
    end

    private def add_program(text : String, type : LibGL::UInt)
      shader = LibGL.create_shader(type)
      if shader == 0
        shader_error_code = LibGL.get_error
        puts "Error #{shader_error_code}: Shader creation failed. Could not find valid memory location when adding shader"
        exit 1
      end

      ptr = text.to_unsafe
      source = [ptr]
      size = [text.size]
      size = Pointer(Int32).new(0)
      LibGL.shader_source(shader, 1, source, size)
      LibGL.compile_shader(shader)

      LibGL.get_shader_iv(shader, LibGL::COMPILE_STATUS, out compile_status)
      if compile_status == LibGL::FALSE
        LibGL.get_shader_info_log(shader, 1024, nil, out compile_log)
        compile_log_str = String.new(pointerof(compile_log))
        compile_error_code = LibGL.get_error
        puts "Error #{compile_error_code}: Failed compiling shader '#{text}': #{compile_log_str}"
        exit 1
      end

      LibGL.attach_shader(@resource.program, shader)
    end
  end
end
