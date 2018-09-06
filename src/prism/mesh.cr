require "lib_gl"
require "./util"

module Prism

  class Mesh

    @vbo : LibGL::UInt
    @ibo : LibGL::UInt
    @size : Int32

    def initialize
      LibGL.gen_buffers(1, out @vbo)
      LibGL.gen_buffers(1, out @ibo)
      @size = 0
    end

    def add_verticies(verticies : Array(Vertex), indicies : Array(LibGL::Int))
        @size = indicies.size

        LibGL.bind_buffer(LibGL::ARRAY_BUFFER, @vbo)
        LibGL.buffer_data(LibGL::ARRAY_BUFFER, verticies.size * Vertex::SIZE * sizeof(Float32), Util.flatten_verticies(verticies), LibGL::STATIC_DRAW)

        LibGL.bind_buffer(LibGL::ELEMENT_ARRAY_BUFFER, @ibo)
        LibGL.buffer_data(LibGL::ELEMENT_ARRAY_BUFFER, indicies.size * Vertex::SIZE * sizeof(Float32), indicies, LibGL::STATIC_DRAW)
    end

    def draw
      LibGL.enable_vertex_attrib_array(0)

      LibGL.bind_buffer(LibGL::ARRAY_BUFFER, @vbo)
      offset = Pointer(Void).new(0)
      LibGL.vertex_attrib_pointer(0, 3, LibGL::FLOAT, LibGL::FALSE, Vertex::SIZE * sizeof(Float32), offset)

      LibGL.bind_buffer(LibGL::ELEMENT_ARRAY_BUFFER, @ibo)
      indicies_offset = Pointer(Void).new(0)
      LibGL.draw_elements(LibGL::TRIANGLES, @size, LibGL::UNSIGNED_INT, indicies_offset)

      LibGL.disable_vertex_attrib_array(0)
    end

  end

end
