module Prism
  class ShapeFactory
    def self.plain(width : Float32, depth : Float32)
      verticies = [
        Vertex.new(Vector3f.new(-width, 0, -depth), Vector2f.new(0, 0)),
        Vertex.new(Vector3f.new(-width, 0, depth * 3), Vector2f.new(0, 1)),
        Vertex.new(Vector3f.new(width * 3, 0, -depth), Vector2f.new(1, 0)),
        Vertex.new(Vector3f.new(width * 3, 0, depth * 3), Vector2f.new(1, 1)),
      ]

      indicies = Array(LibGL::Int){
        0, 1, 2,
        2, 1, 3,
      }

      mesh = Mesh.new(verticies, indicies, true)
      material = Material.new
      material.add_texture("diffuse", Texture.new("defaultTexture.png"))
      material.add_float("specularIntensity", 1)
      material.add_float("specularPower", 8)

      GameObject.new.add_component(MeshRenderer.new(mesh, material))
    end
  end
end
