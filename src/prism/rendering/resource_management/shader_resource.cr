require "lib_gl"

module Prism
  class ShaderResource
    @program : LibGL::UInt
    @ref_count : Int32

    getter program

    def initialize
      @program = LibGL.create_program
      @ref_count = 1

      if @program == 0
        program_error_code = LibGL.get_error
        puts "Error #{program_error_code}: Shader creation failed. Could not find valid memory location in constructor"
        exit 1
      end
    end

    # garbage collection
    # TODO: make sure this is getting called
    def finalize
      puts "cleaning up garbage"
      LibGL.delete_buffers(1, out @program)
    end

    # Adds a reference to this resource
    def add_reference
      @ref_count += 1
    end

    # Removes a reference from the resource.
    # Returns `true` if there are no more references to this resource
    #
    def remove_reference
      @ref_count = -1
      return @ref_count == 0
    end
  end
end
