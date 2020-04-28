module Prism
  class Mesh
    # Generates a flat plane mesh
    def self.plane(width : Float32, depth : Float32)
      plane(width, depth, {
        bottom_left:  Vector2f.new(0, 0),
        top_left:     Vector2f.new(0, 1),
        bottom_right: Vector2f.new(1, 0),
        top_right:    Vector2f.new(1, 1),
      })
    end

    def self.plane(width : Float32, depth : Float32, texture_coords : TextureCoords)
      field_depth = 1.0f32
      field_width = 1.0f32

      verticies = [
        Prism::Vertex.new(Vector3f.new(0, 0, 0), texture_coords[:bottom_left]),
        Prism::Vertex.new(Vector3f.new(0, 0, depth), texture_coords[:top_left]),
        Prism::Vertex.new(Vector3f.new(width, 0, 0), texture_coords[:bottom_right]),
        Prism::Vertex.new(Vector3f.new(width, 0, depth), texture_coords[:top_right]),
      ]

      indicies = Array(Int32){
        0, 1, 2,
        2, 1, 3,
      }

      Mesh.new(verticies, indicies, true)
    end
  end
end
