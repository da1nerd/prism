require "lib_gl"
require "../src/prism"
require "./mesh_renderer"

include Prism

class TestGame < Prism::Game
  
  def init
    field_depth = 10.0f32
    field_width = 10.0f32

    verticies = [
      Vertex.new(Vector3f.new(-field_width, 0, -field_depth), Vector2f.new(0, 0)),
      Vertex.new(Vector3f.new(-field_width, 0, field_depth * 3), Vector2f.new(0, 1)),
      Vertex.new(Vector3f.new(field_width * 3, 0, -field_depth), Vector2f.new(1, 0)),
      Vertex.new(Vector3f.new(field_width * 3, 0, field_depth * 3), Vector2f.new(1, 1))
    ]

    indicies = Array(LibGL::Int) {
      0, 1, 2,
      2, 1, 3
    }

    mesh = Mesh.new(verticies, indicies, true);
    material = Material.new(Texture.new("test.png"), Vector3f.new(1,1,1), 1, 8);

    mesh_renderer = MeshRenderer.new(mesh, material)

    plane_object = GameObject.new
    plane_object.add_component(mesh_renderer)
    plane_object.transform.pos(0, -1, 5)

    get_root_object.add_child(plane_object)

  end

end
