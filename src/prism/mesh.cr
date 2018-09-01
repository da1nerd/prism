require "lib_gl"
require "./util"

module Prism

  class Mesh

    @vbo : LibGL::UInt
    @size : Int32

    def initialize
      @size = 0
      LibGL.gen_buffers(1, out @vbo)
      # This is temporary
      LibGL.bind_buffer(LibGL::ARRAY_BUFFER, @vbo)
    end

    def add_verticies(verticies : Array(Vertex))
        @size = verticies.size #verticies.size * Vertex::SIZE
        LibGL.bind_buffer(LibGL::ARRAY_BUFFER, @vbo)
        buffer = Util.create_flipped_buffer(verticies)

        data = [
          -1f32, -1f32, 0f32,
          -1f32, 1f32, 0f32,
          0f32, 1f32, 0f32
        ]
        # ptr = Pointer(Void).new(data.object_id)
        # ptr = data[0].to_unsafe

        # LibGL.buffer_data(LibGL::ARRAY_BUFFER, @size * Vertex::SIZE * sizeof(Float32), ptr, LibGL::STATIC_DRAW)
    end

    def draw
      LibGL.enable_vertex_attrib_array(0)

      data = [
        -1f32, -1f32, 0f32,
        0f32, 1f32, 0f32,
        1f32, -1f32, 0f32
      ]

      LibGL.buffer_data(LibGL::ARRAY_BUFFER, 3 * Vertex::SIZE * sizeof(Float32), data, LibGL::STATIC_DRAW)

      offset = Pointer(Void).new(0)
      LibGL.vertex_attrib_pointer(0, 3, LibGL::FLOAT, LibGL::FALSE, 0, offset)
      #
      LibGL.draw_arrays(LibGL::TRIANGLES, 0, 9)
      #
      LibGL.disable_vertex_attrib_array(0)
    end

  end

end
