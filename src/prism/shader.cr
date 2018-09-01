require "lib_gl"

module Prism

  class Shader

    @program : Int32

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
    def compile_shader
      LibGL.link_program(@program)

      if LibGL.get_shader(@program, LibGL::LINK_STATUS) == 0
        puts LibGL.get_shader_info_log(@program, 1024)
        exit 1
      end

      LibGL.validate_program(@program)

      if LibGL.get_shader(@program, LibGL::VALIDATE_STATUS) == 0
        puts LibGL.get_shader_info_log(@program, 1024)
        exit 1
      end
    end

    private def add_program(text : String, type : LibGL::UInt)
      shader = LibGL.create_shader(type)
      if shader == 0
        puts "Shader creation failed. Could not find valid memory location when adding shader"
        exit 1
      end

      LibGL.shader_source(shader, text)
      LibGL.compiler_shader(shader)

      if LibGL.get_shader(shader, LibGL::COMPILE_STATUS) == 0
        puts LibGL.get_shader_info_log(shader, 1024)
        exit 1
      end

      LibGL.attach_shader(shader, @program)

    end

  end

end
