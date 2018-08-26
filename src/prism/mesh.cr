require "lib_gl"
require "./util"

module Prism

  class Mesh

    @vbo : UInt32
    @size : Int32

    def initialize
      @size = 0
      LibGL.gen_buffers(@size, out @vbo)
    end

    def add_verticies(verticies : Array(Vertex))
        @size = verticies.size #verticies.size * Vertex::SIZE
        LibGL.bind_buffer(LibGL::ARRAY_BUFFER, @vbo)
        buffer = Util.create_flipped_buffer(verticies)
        ptr = buffer.to_unsafe
        LibGL.buffer_data(LibGL::ARRAY_BUFFER, @size * Vertex::SIZE * sizeof(Float32), ptr, LibGL::STATIC_DRAW)
    end

    def draw
      LibGL.enable_vertex_attrib_array(0)

      LibGL.bind_buffer(LibGL::ARRAY_BUFFER, @vbo)

      # TODO: what is the last argument pointing to?
      # if pointer isnot null, a non-zero named buffer object must be bound to
      # the GL_ARRAY_BUFFER target (see glBindBuffer)
      offset = 0
      offset_ptr = pointerof(offset)
      LibGL.vertex_attrib_pointer(0, Vertex::SIZE, LibGL::FLOAT, LibGL::FALSE, Vertex::SIZE * sizeof(Float32), offset_ptr)

      LibGL.draw_arrays(LibGL::TRIANGLES, 0, @size)

      LibGL.disable_vertex_attrib_array(0)
    end

  end

end