require "lib_gl"

module Prism

  class Shader

    @program : LibGL::UInt

    def initialize
      @program = LibGL.create_program()

      if @program == 0
        puts "Shader creation failed. Could not find valid memory location in constructor"
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

    # compiles the shader
    def compile
      LibGL.link_program(@program)

      LibGL.get_program_iv(@program, LibGL::LINK_STATUS, out link_status)
      if link_status == 0
        LibGL.get_program_info_log(@program, 1024, out link_log_len, out link_log)
        puts link_log
        exit 1
      end

      LibGL.validate_program(@program)

      LibGL.get_program_iv(@program, LibGL::VALIDATE_STATUS, out validate_status)
      if validate_status == 0
        LibGL.get_program_info_log(@program, 1024, out validate_log_len, out validate_log)
        puts validate_log
        exit 1
      end
    end

    private def add_program(text : String, type : LibGL::UInt)
      shader = LibGL.create_shader(type)
      if shader == 0
        puts "Shader creation failed. Could not find valid memory location when adding shader"
        exit 1
      end

      ptr = text.to_unsafe
      source = [ptr]
      size = [text.size]
      # TODO: I think shader_source is not getting the correct parameters
      # Follow this example https://www.khronos.org/opengl/wiki/Example_Code
      size = Pointer(Int32).new(0)
      LibGL.shader_source(shader, 1, source, size)
      LibGL.compile_shader(shader)

      LibGL.get_shader_iv(shader, LibGL::COMPILE_STATUS, out compile_status)
      if compile_status == 0
        LibGL.get_shader_info_log(shader, 1024, out log_len, out log)
        puts log
        exit 1
      end

      LibGL.attach_shader(@program, shader)

    end

  end

end
