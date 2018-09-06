require "lib_gl"
require "./vector3f"
require "./matrix4f"

module Prism

  class Shader

    @program : LibGL::UInt
    @uniforms : Hash(String, Int32)

    def initialize
      @program = LibGL.create_program()
      @uniforms = {} of String => Int32

      if @program == 0
        program_error_code = LibGL.get_error()
        puts "Error #{program_error_code}: Shader creation failed. Could not find valid memory location in constructor"
        exit 1
      end
    end

    # uses the shader
    def bind
      LibGL.use_program(@program)
    end

    def add_vertex_shader(text : String)
      add_program(text, LibGL::VERTEX_SHADER)
    end

    def add_geometry_shader(text : String)
        add_program(text, LibGL::GEOMETRY_SHADER)
    end

    def add_fragment_shader(text : String)
        add_program(text, LibGL::FRAGMENT_SHADER)
    end

    # Adds a uniform variable for the shader to keep track of
    # The shader must be compiled before adding uniforms.
    def add_uniform( uniform : String)
      uniform_location = LibGL.get_uniform_location(@program, uniform);

      if uniform_location == -1
        uniform_error_code = LibGL.get_error()
        puts "Error #{uniform_error_code}: Could not find uniform: #{uniform_location}"
        exit 1
      end

      @uniforms[uniform] = uniform_location
    end

    # Sets an integer uniform variable value
    def set_uniform( name : String, value : LibGL::Int)
      LibGL.uniform_1i(@uniforms[name], value)
    end

    # Sets a float uniform variable value
    def set_uniform( name : String, value : LibGL::Float)
      LibGL.uniform_1f(@uniforms[name], value)
    end

    # Sets a 3 dimensional float vector value to a uniform variable
    def set_uniform( name : String, value : Vector3f)
      LibGL.uniform_3f(@uniforms[name], value.x, value.y, value.z)
    end

    # Sets a 4 dimensional matrix float value to a uniform variable
    def set_uniform( name : String, value : Matrix4f)
      LibGL.uniform_matrix_4fv(@uniforms[name], true, value.to_a)
    end

    # compiles the shader
    def compile
      LibGL.link_program(@program)

      LibGL.get_program_iv(@program, LibGL::LINK_STATUS, out link_status)
      if link_status == LibGL::FALSE
        LibGL.get_program_info_log(@program, 1024, nil, out link_log)
        link_log_str = String.new(pointerof(link_log))
        link_error_code = LibGL.get_error()
        puts "Error #{link_error_code}: Failed linking shader program: #{link_log_str}"
        exit 1
      end

      LibGL.validate_program(@program)

      LibGL.get_program_iv(@program, LibGL::VALIDATE_STATUS, out validate_status)
      if validate_status == LibGL::FALSE
        LibGL.get_program_info_log(@program, 1024, nil, out validate_log)
        validate_log_str = String.new(pointerof(validate_log))
        validate_error_code = LibGL.get_error()
        puts "Error #{validate_error_code}: Failed validating shader program: #{validate_log_str}"
        exit 1
      end

      # TODO: delete the shaders since they are linked into the program and we no longer need them
      # LibGL.delete_shader(shader)
    end

    private def add_program(text : String, type : LibGL::UInt)
      shader = LibGL.create_shader(type)
      if shader == 0
        shader_error_code = LibGL.get_error()
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
        compile_error_code = LibGL.get_error()
        puts "Error #{compile_error_code}: Failed compiling shader: #{compile_log_str}"
        exit 1
      end

      LibGL.attach_shader(@program, shader)
    end

  end

end
