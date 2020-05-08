module Prism::Shader::Loader
  extend self

  # Loads a shader program
  def load_program(file_name : String, &shader_reader : String -> String) : CompiledProgram
    # create a new resource and register it with the list of active programs
    resource = CompiledProgram.new

    # read the vertex and fragment shader files
    vertex_shader_text = read_shader_file("#{file_name}.vs", &shader_reader)
    fragment_shader_text = read_shader_file("#{file_name}.fs", &shader_reader)

    # load the shader code into OpenGL
    vertex_shader_id = load_shader(vertex_shader_text, LibGL::VERTEX_SHADER)
    fragment_shader_id = load_shader(fragment_shader_text, LibGL::FRAGMENT_SHADER)

    # attach the now-loaded shader code to the program.
    resource.attach_shader(vertex_shader_id)
    resource.attach_shader(fragment_shader_id)

    compile_shader_program(resource)

    # trash shaders
    LibGL.delete_shader(vertex_shader_id)
    LibGL.delete_shader(fragment_shader_id)

    # searches for attributes in the vertex shader code and automatically binds them to the program
    automatically_bind_attributes(resource, vertex_shader_text)

    # searches for uniforms in the shader code and automatically binds them to the program
    add_all_uniforms(resource, vertex_shader_text)
    add_all_uniforms(resource, fragment_shader_text)

    return resource
  end

  # Loads a shader program
  protected def read_shader_file(file_path : String, &file_reader : String -> String) : String
    input = file_reader.call file_path
    # strip out comments. Not the most efficient but it works for now.
    clean_input = String.build do |io|
      input.each_line() do |line|
        next if line.starts_with?(/\s*\/\//)
        io << line << "\n"
      end
    end
    evaluate_includes clean_input, &file_reader
  end

  # Searches for include statements and combines them with the *input*
  # An include statement looks like `#include "somefile.ext"`
  private def evaluate_includes(input : String, &file_reader : String -> String) : String
    shader_source = ""

    input.each_line() do |line|
      include_match = line.scan(/^\s*\#include\s+["<]([^">]*)[>"]/)
      if include_match.size > 0
        shader_source += read_shader_file(include_match[0][1], &file_reader)
      else
        shader_source += line + "\n"
      end
    end

    return shader_source
  end

  # compiles the shader
  private def compile_shader_program(resource : CompiledProgram)
    LibGL.link_program(resource.program)

    LibGL.get_program_iv(resource.program, LibGL::LINK_STATUS, out link_status)
    if link_status == LibGL::FALSE
      LibGL.get_program_info_log(resource.program, 1024, nil, out link_log)
      link_log_str = String.new(pointerof(link_log))
      link_error_code = LibGL.get_error
      raise "Error #{link_error_code}: Failed linking shader program: #{link_log_str}"
    end

    LibGL.validate_program(resource.program)

    LibGL.get_program_iv(resource.program, LibGL::VALIDATE_STATUS, out validate_status)
    if validate_status == LibGL::FALSE
      LibGL.get_program_info_log(resource.program, 1024, nil, out validate_log)
      validate_log_str = String.new(pointerof(validate_log))
      validate_error_code = LibGL.get_error
      raise "Error #{validate_error_code}: Failed validating shader program: #{validate_log_str}"
    end
  end

  # Parses the shader text for attribute delcarations and automatically adds them
  # This supports older versions of glsl as well as newer versions.
  #
  # This is handy because you don't need to worry about declaring the attributes yourself.
  # You only need to:
  # 1. define the attributes in your glsl code
  # 2. write the data to the buffer. `Model`
  private def automatically_bind_attributes(resource : CompiledProgram, shader_text : String)
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

      resource.bind_attribute(attribute_name, attribute_number)
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
        raise "Error: #{struct_name} at position #{start} has no properties"
      end

      structs[struct_name] = GLSLStruct.new(struct_name, properties)
      start_location = shader_text.index(/\b#{keyword}\b/, end_brace_location)
    end
    return structs
  end

  # Adds a uniform while expanding it's struct properties as needed
  private def register_uniform(resource : CompiledProgram, uniform_name : String, uniform_type : String, structs : Hash(String, GLSLStruct))
    if structs.has_key?(uniform_type)
      properties = structs[uniform_type].properties
      0.upto(properties.size - 1) do |i|
        prop : GLSLProperty = properties[i]
        register_uniform(resource, "#{uniform_name}.#{prop.name}", prop.prop_type, structs)
      end
    else
      # add the final uniform
      uniform_location = LibGL.get_uniform_location(resource.program, uniform_name)
      if uniform_location == -1
        uniform_error_code = LibGL.get_error
        raise Exception.new("Error #{uniform_error_code}: Could not find location for uniform '#{uniform_name}'.")
      end

      resource.uniforms[uniform_name] = uniform_location
    end
  end

  # Parses the shader text for uniform declarations and automatically adds them
  private def add_all_uniforms(resource : CompiledProgram, shader_text : String)
    structs = find_uniform_structs(shader_text)

    keyword = "uniform"
    start_location = shader_text.index(/\b#{keyword}\b/)
    while start = start_location
      end_location = shader_text.index(";", start).not_nil!
      uniform_line = shader_text[start..end_location]
      matches = uniform_line.scan(/\b#{keyword}\b\s+([a-zA-Z0-9_]+)\s+([a-zA-Z0-9_]+)/)
      uniform_type = matches[0][1]
      uniform_name = matches[0][2]

      resource.uniform_names.push(uniform_name)
      resource.uniform_types.push(uniform_type)
      register_uniform(resource, uniform_name, uniform_type, structs)

      start_location = shader_text.index(/\b#{keyword}\b/, end_location)
    end
  end

  # Adds a shader program to OpenGL
  private def load_shader(text : String, type : LibGL::UInt) : UInt32
    shader_id = LibGL.create_shader(type)
    if shader_id == 0
      shader_error_code = LibGL.get_error
      raise "Error #{shader_error_code}: Shader creation failed. Could not find valid memory location when adding shader"
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
      raise "Error #{compile_error_code}: Failed compiling shader.\n'#{text}': #{compile_log_str}"
    end
    shader_id
  end
end
