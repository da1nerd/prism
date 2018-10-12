require "lib_gl"

module Prism
  class TextureResource
    @id : LibGL::UInt
    @ref_count : Int32

    getter id

    def initialize
      LibGL.gen_textures(1, out @id)
      @ref_count = 1
    end

    # garbage collection
    # TODO: make sure this is getting called
    def finalize
      puts "cleaning up garbage"
      LibGL.delete_buffers(1, out @id)
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
