require "lib_gl"

module Prism

  class Mesh

    @vbo : UInt32
    @size : Pointer(Int32)

    def initialize
      size = 0
      @size = pointerof(size)
      LibGL.gen_buffers(@size.value, out @vbo)
    end

    def add_verticies(verticies : Array(Vertex))
        size = verticies.size #verticies.size * Vertex::SIZE
        LibGL.bind_buffer(LibGL::ARRAY_BUFFER, @vbo)
        # TODO: do we need to re-organize the data?
        LibGL.buffer_data(LibGL::ARRAY_BUFFER, @size.value, verticies, LibGL::STATIC_DRAW)
    end

    def draw
      size = @size
      return unless size

      LibGL.enable_vertex_attrib_array(0)

      LibGL.bind_buffer(LibGL::ARRAY_BUFFER, @vbo)

      x = 0
      pointer = pointerof(x)
      LibGL.vertex_attrib_pointer(0, 3, LibGL::FLOAT, 0u8, Vertex::SIZE * 4, pointer)

      LibGL.draw_arrays(LibGL::TRIANGLES, 0, size.value)

      LibGL.disable_vertex_attrib_array(0)
    end

  end

end
