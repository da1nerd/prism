require "lib_gl"
require "./util"

module Prism

  class Mesh

    @vbo : LibGL::UInt
    @size : Int32

    def initialize
      LibGL.gen_buffers(1, out @vbo)
      @size = 0
    end

    def add_verticies(verticies : Array(Vertex))
        @size = verticies.size

        LibGL.bind_buffer(LibGL::ARRAY_BUFFER, @vbo)
        LibGL.buffer_data(LibGL::ARRAY_BUFFER, verticies.size * Vertex::SIZE * sizeof(Float32), Util.flatten_verticies(verticies), LibGL::STATIC_DRAW)
    end

    def draw
      LibGL.enable_vertex_attrib_array(0)

      LibGL.bind_buffer(LibGL::ARRAY_BUFFER, @vbo)
      offset = Pointer(Void).new(0)
      LibGL.vertex_attrib_pointer(0, 3, LibGL::FLOAT, LibGL::FALSE, Vertex::SIZE * sizeof(Float32), offset)

      LibGL.draw_arrays(LibGL::TRIANGLES, 0, @size)

      LibGL.disable_vertex_attrib_array(0)
    end

  end

end
