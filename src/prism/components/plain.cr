module Prism
  class Plain < Mesh
    def initialize(width, height)
      field_depth = 10.0f32
      field_width = 10.0f32

      verticies = [
        Vertex.new(Vector3f.new(-field_width, 0, -field_depth), Vector2f.new(0, 0)),
        Vertex.new(Vector3f.new(-field_width, 0, field_depth * 3), Vector2f.new(0, 1)),
        Vertex.new(Vector3f.new(field_width * 3, 0, -field_depth), Vector2f.new(1, 0)),
        Vertex.new(Vector3f.new(field_width * 3, 0, field_depth * 3), Vector2f.new(1, 1)),
      ]

      indicies = Array(GraphicsInt){
        0, 1, 2,
        2, 1, 3,
      }

      initialize(verticies, indicies, true)
    end
  end
end
