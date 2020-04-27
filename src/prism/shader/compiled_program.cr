require "lib_gl"
require "../reference_counter.cr"

module Prism::Shader
  # An internal representation of a `ShaderProgram`.
  # Manages the state of a single GL shader program.
  #
  # Keeps track of references to a single GL shader program
  # and performs cleanup operations during garbage collection
  class CompiledProgram < Prism::ReferenceCounter
    @program : LibGL::UInt
    @uniforms : Hash(String, Int32)
    @uniform_names : Array(String)
    @uniform_types : Array(String)
    @shaders : Array(LibGL::UInt)
    @num_attributes : LibGL::UInt

    getter program, uniforms, uniform_names, uniform_types, num_attributes

    def initialize
      @program = LibGL.create_program
      @uniforms = {} of String => Int32
      @uniform_names = [] of String
      @uniform_types = [] of String
      @shaders = [] of LibGL::UInt
      @num_attributes = 0

      if @program == 0
        program_error_code = LibGL.get_error
        puts "Error #{program_error_code}: Shader program creation failed. Could not find valid memory location in constructor"
        exit 1
      end
    end

    # Returns the shader program id
    def id
      @program
    end

    # Attaches a shader to the program
    def attach_shader(shader_id : LibGL::UInt)
      @shaders.push(shader_id)
      LibGL.attach_shader(@program, shader_id)
    end

    # Binds an attribute to the program
    # In older versions of glsl code this will be variables prefixed with `attribute` keyword.
    # Newer versions of glsl use the `in` keyword.
    # In both cases these represent values stored in the "vertex attribute buffer" or "vertex buffer object" (vbo).
    # See `MeshResource.vbo`.
    def bind_attribute(variable_name : String, attribute_location : LibGL::Int)
      LibGL.bind_attrib_location(@program, attribute_location, variable_name)
      @num_attributes += 1
    end

    # garbage collection
    def finalize
      @shaders.each do |id|
        LibGL.detach_shader(@program, id)
        LibGL.delete_shader(id)
      end
      LibGL.delete_program(@program)
    end
  end
end
