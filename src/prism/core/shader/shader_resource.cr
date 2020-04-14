require "lib_gl"
require "../reference_counter.cr"

module Prism::Core
  # Manages the state of a single GL shader program.
  #
  # Keeps track of references to a single GL shader program
  # and performs cleanup operations during garbage collection
  class ShaderResource < ReferenceCounter
    @program : LibGL::UInt
    @uniforms : Hash(String, Int32)
    @uniform_names : Array(String)
    @uniform_types : Array(String)
    @shaders : Array(LibGL::UInt)

    getter program, uniforms, uniform_names, uniform_types

    def initialize
      @program = LibGL.create_program
      @uniforms = {} of String => Int32
      @uniform_names = [] of String
      @uniform_types = [] of String
      @shaders = [] of LibGL::UInt

      if @program == 0
        program_error_code = LibGL.get_error
        puts "Error #{program_error_code}: Shader program creation failed. Could not find valid memory location in constructor"
        exit 1
      end
    end

    # Attaches a shader to the program
    def attach_shader(shader_id : LibGL::UInt)
      @shaders.push(shader_id)
      LibGL.attach_shader(@program, shader_id)
    end

    # garbage collection
    # TODO: make sure this is getting called
    def finalize
      puts "cleaning up shader resource garbage"
      @shaders.each do |id|
        LibGL.detach_shader(@program, id)
        LibGL.delete_shader(id)
      end
      LibGL.delete_program(@program)
      # TODO: do we need this?
      LibGL.delete_buffers(1, out @program)
    end
  end
end
