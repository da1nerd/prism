require "./shape"

module Prism::Common::Objects
  # A basic cube shape.
  # You can configure the *size* of the cube to make it smaller or bigger.
  class Cube < Shape
    def initialize(@size : Float32)
      initialize(@size, {
        bottom_left:  Vector2f.new(0, 0),
        top_left:     Vector2f.new(0, 1),
        bottom_right: Vector2f.new(1, 0),
        top_right:    Vector2f.new(1, 1),
      })
    end

    def initialize(@size : Float32, @texture_coords : TextureCoords)
      super()

      field_depth = 1.0f32
      field_width = 1.0f32

      verticies = [
        # bottom
        Core::Vertex.new(Vector3f.new(0, 0, 0), @texture_coords[:bottom_left]),
        Core::Vertex.new(Vector3f.new(0, 0, @size), @texture_coords[:bottom_right]),
        Core::Vertex.new(Vector3f.new(@size, 0, @size), @texture_coords[:top_right]),
        Core::Vertex.new(Vector3f.new(@size, 0, 0), @texture_coords[:top_left]),

        # top
        Core::Vertex.new(Vector3f.new(0, @size, 0), @texture_coords[:bottom_left]),
        Core::Vertex.new(Vector3f.new(0, @size, @size), @texture_coords[:bottom_right]),
        Core::Vertex.new(Vector3f.new(@size, @size, @size), @texture_coords[:top_right]),
        Core::Vertex.new(Vector3f.new(@size, @size, 0), @texture_coords[:top_left]),

        # back
        Core::Vertex.new(Vector3f.new(0, 0, @size), @texture_coords[:bottom_left]),
        Core::Vertex.new(Vector3f.new(0, @size, @size), @texture_coords[:bottom_right]),
        Core::Vertex.new(Vector3f.new(@size, @size, @size), @texture_coords[:top_right]),
        Core::Vertex.new(Vector3f.new(@size, 0, @size), @texture_coords[:top_left]),

        # front
        Core::Vertex.new(Vector3f.new(0, 0, 0), @texture_coords[:bottom_left]),
        Core::Vertex.new(Vector3f.new(0, @size, 0), @texture_coords[:bottom_right]),
        Core::Vertex.new(Vector3f.new(@size, @size, 0), @texture_coords[:top_right]),
        Core::Vertex.new(Vector3f.new(@size, 0, 0), @texture_coords[:top_left]),

        # left
        Core::Vertex.new(Vector3f.new(0, 0, 0), @texture_coords[:bottom_left]),
        Core::Vertex.new(Vector3f.new(0, 0, @size), @texture_coords[:bottom_right]),
        Core::Vertex.new(Vector3f.new(0, @size, @size), @texture_coords[:top_right]),
        Core::Vertex.new(Vector3f.new(0, @size, 0), @texture_coords[:top_left]),

        # right
        Core::Vertex.new(Vector3f.new(@size, 0, 0), @texture_coords[:bottom_left]),
        Core::Vertex.new(Vector3f.new(@size, 0, @size), @texture_coords[:bottom_right]),
        Core::Vertex.new(Vector3f.new(@size, @size, @size), @texture_coords[:top_right]),
        Core::Vertex.new(Vector3f.new(@size, @size, 0), @texture_coords[:top_left]),
      ]

      indicies = Array(Core::GraphicsInt){
        0, 3, 2,
        0, 2, 1,

        4, 5, 6,
        4, 6, 7,

        8, 11, 10,
        8, 10, 9,

        12, 13, 14,
        12, 14, 15,

        16, 17, 18,
        16, 18, 19,

        20, 23, 22,
        20, 22, 21,
      }

      @mesh = Core::Mesh.new(verticies, indicies, true)
    end
  end
end
