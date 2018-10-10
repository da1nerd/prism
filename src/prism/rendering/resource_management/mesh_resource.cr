require "lib_gl"

module Prism

  class MeshResource

      @vbo : LibGL::UInt
      @ibo : LibGL::UInt
      @size : Int32
      @ref_count : Int32

      getter vbo, ibo, size
      setter size

      def initialize
        LibGL.gen_buffers(1, out @vbo)
        LibGL.gen_buffers(1, out @ibo)
        @size = 0
        @ref_count = 1
      end

      # garbage collection
      def finalize
        # TODO: make sure this is getting called
        puts "cleaning up garbage"
        LibGL.delete_buffers(1, out @vbo)
        LibGL.delete_buffers(1, out @ibo)
      end

      # Adds a reference to this resource
      def add_reference
        @ref_count += 1
      end

      # Removes a reference from the resource.
      # Returns `true` if there are no more references to this resource
      #
      def remove_reference
        @ref_count  =- 1
        return @ref_count == 0
      end
  end

end
