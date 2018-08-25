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
        # TODO: do we need to re-organize the data?
        # see this https://www.khronos.org/opengl/wiki/VBO_-_just_examples
        LibGL.buffer_data(LibGL::ARRAY_BUFFER, Vertex::SIZE * 4, Util.create_flipped_buffer(verticies), LibGL::STATIC_DRAW)
    end

    def draw
      LibGL.enable_vertex_attrib_array(0)

      LibGL.bind_buffer(LibGL::ARRAY_BUFFER, @vbo)

      # TODO: what is the last argument pointing to?
      LibGL.vertex_attrib_pointer(0, 3, LibGL::FLOAT, LibGL::FALSE, Vertex::SIZE * 4, 0)

      LibGL.draw_arrays(LibGL::TRIANGLES, 0, @size)

      LibGL.disable_vertex_attrib_array(0)
    end

  end

end
