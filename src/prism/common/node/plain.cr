module Prism::Common::Node
  class Plain < Shape
    def initialize(@width : Float32, @depth : Float32)
      initialize(@width, @depth, {
        bottom_left:  Vector2f.new(0, 0),
        top_left:     Vector2f.new(0, 1),
        bottom_right: Vector2f.new(1, 0),
        top_right:    Vector2f.new(1, 1),
      })
    end

    def initialize(@width : Float32, @depth : Float32, @texture_coords : SpriteCoords)
      super()

      field_depth = 1.0f32
      field_width = 1.0f32

      verticies = [
        Core::Vertex.new(Vector3f.new(0, 0, 0), @texture_coords[:bottom_left]),         # Vector2f.new(0, 0)),
        Core::Vertex.new(Vector3f.new(0, 0, @depth), @texture_coords[:top_left]),       # Vector2f.new(0, 1)),
        Core::Vertex.new(Vector3f.new(@width, 0, 0), @texture_coords[:bottom_right]),   # Vector2f.new(1, 0)),
        Core::Vertex.new(Vector3f.new(@width, 0, @depth), @texture_coords[:top_right]), # Vector2f.new(1, 1))
      ]

      indicies = Array(Core::GraphicsInt){
        0, 1, 2,
        2, 1, 3,
      }

      @mesh = Core::Mesh.new(verticies, indicies, true)
    end
  end
end
