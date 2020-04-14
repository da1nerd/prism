require "lib_gl"
require "./reference_counter.cr"

module Prism::Core
  # Manages the state of a single GL mesh.
  #
  # Keeps track of references to a single GL mesh (represented by several buffers)
  # and performs cleanup operations during garbage collection
  class MeshResource < ReferenceCounter
    # Vertex buffer object
    @vbo : LibGL::UInt
    # Indicies buffer object
    @ibo : LibGL::UInt
    @size : Int32

    getter vbo, ibo, size
    setter size

    def initialize
      LibGL.gen_buffers(1, out @vbo)
      LibGL.gen_buffers(1, out @ibo)
      @size = 0
    end

    # garbage collection
    # TODO: make sure this is getting called
    def finalize
      puts "cleaning up mesh resource garbage"
      LibGL.delete_buffers(1, out @vbo)
      LibGL.delete_buffers(1, out @ibo)
    end
  end
end
