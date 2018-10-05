require "lib_gl"
require "../src/prism"

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

    directional_light_object = GameObject.new()
    directional_light = DirectionalLight.new(Vector3f.new(0,0,1), 0.4, Vector3f.new(1,1,1))
    directional_light_object.add_component(directional_light)

    point_light_object = GameObject.new()
    point_light = PointLight.new(Vector3f.new(0,1,0), 0.4, Vector3f.new(0,0,1))
    point_light_object.add_component(point_light)

    spot_light_object = GameObject.new()
    spot_light = SpotLight.new(Vector3f.new(0,1,1), 0.4, Vector3f.new(0,0,0.1), Vector3f.new(1, 0, 0), 0.7)
    spot_light_object.add_component(spot_light)

    spot_light_object.transform.pos(5, 0, 5)

    get_root_object.add_child(plane_object)
    get_root_object.add_child(directional_light_object)
    get_root_object.add_child(point_light_object)
    get_root_object.add_child(spot_light_object)
  end

end
