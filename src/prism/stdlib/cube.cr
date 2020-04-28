require "annotations"

module Prism
  class Mesh
    # Generates a cube mesh
    def self.cube(size : Float32) : Prism::Mesh
      cube(size, {
        bottom_left:  Vector2f.new(0, 0),
        top_left:     Vector2f.new(0, 1),
        bottom_right: Vector2f.new(1, 0),
        top_right:    Vector2f.new(1, 1),
      })
    end

    def self.cube(size : Float32, texture_coords : TextureCoords) : Prism::Mesh
      field_depth = 1.0f32
      field_width = 1.0f32

      verticies = [
        # bottom
        Prism::Vertex.new(Vector3f.new(0, 0, 0), texture_coords[:bottom_left]),
        Prism::Vertex.new(Vector3f.new(0, 0, size), texture_coords[:bottom_right]),
        Prism::Vertex.new(Vector3f.new(size, 0, size), texture_coords[:top_right]),
        Prism::Vertex.new(Vector3f.new(size, 0, 0), texture_coords[:top_left]),

        # top
        Prism::Vertex.new(Vector3f.new(0, size, 0), texture_coords[:bottom_left]),
        Prism::Vertex.new(Vector3f.new(0, size, size), texture_coords[:bottom_right]),
        Prism::Vertex.new(Vector3f.new(size, size, size), texture_coords[:top_right]),
        Prism::Vertex.new(Vector3f.new(size, size, 0), texture_coords[:top_left]),

        # back
        Prism::Vertex.new(Vector3f.new(0, 0, size), texture_coords[:bottom_left]),
        Prism::Vertex.new(Vector3f.new(0, size, size), texture_coords[:bottom_right]),
        Prism::Vertex.new(Vector3f.new(size, size, size), texture_coords[:top_right]),
        Prism::Vertex.new(Vector3f.new(size, 0, size), texture_coords[:top_left]),

        # front
        Prism::Vertex.new(Vector3f.new(0, 0, 0), texture_coords[:bottom_left]),
        Prism::Vertex.new(Vector3f.new(0, size, 0), texture_coords[:bottom_right]),
        Prism::Vertex.new(Vector3f.new(size, size, 0), texture_coords[:top_right]),
        Prism::Vertex.new(Vector3f.new(size, 0, 0), texture_coords[:top_left]),

        # left
        Prism::Vertex.new(Vector3f.new(0, 0, 0), texture_coords[:bottom_left]),
        Prism::Vertex.new(Vector3f.new(0, 0, size), texture_coords[:bottom_right]),
        Prism::Vertex.new(Vector3f.new(0, size, size), texture_coords[:top_right]),
        Prism::Vertex.new(Vector3f.new(0, size, 0), texture_coords[:top_left]),

        # right
        Prism::Vertex.new(Vector3f.new(size, 0, 0), texture_coords[:bottom_left]),
        Prism::Vertex.new(Vector3f.new(size, 0, size), texture_coords[:bottom_right]),
        Prism::Vertex.new(Vector3f.new(size, size, size), texture_coords[:top_right]),
        Prism::Vertex.new(Vector3f.new(size, size, 0), texture_coords[:top_left]),
      ]

      indicies = Array(Int32){
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

      Mesh.new(verticies, indicies, true)
    end
  end
end
