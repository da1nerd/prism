require "../src/prism/**"
require "lib_gl"

include Prism

class ModelDemo < Core::GameEngine
  def init
    # Add model to look at
    # material2 = Material.new
    # material2.add_texture("diffuse", Texture.new("bricks.png"))
    # material2.add_float("specularIntensity", 1)
    # material2.add_float("specularPower", 8)
    # monkey = GameObject.new().add_component(MeshRenderer.new(Mesh.new("monkey3.obj"), material2))
    # monkey.transform.scale = Vector3f.new(0.2, 0.2, 0.2)

    # aspect = 800 / 600
    # cam = Camera.new(Prism.to_rad(65.0f32), aspect.to_f32, 0.01f32, 1000.0f32)
    # monkey.add_component(cam)
    # add_object(monkey)

    # # add camera

    field_depth = 10.0f32
    field_width = 10.0f32

    verticies = [
      Core::Vertex.new(Vector3f.new(-field_width, 0, -field_depth), Vector2f.new(0, 0)),
      Core::Vertex.new(Vector3f.new(-field_width, 0, field_depth * 3), Vector2f.new(0, 1)),
      Core::Vertex.new(Vector3f.new(field_width * 3, 0, -field_depth), Vector2f.new(1, 0)),
      Core::Vertex.new(Vector3f.new(field_width * 3, 0, field_depth * 3), Vector2f.new(1, 1)),
    ]

    indicies = Array(LibGL::Int){
      0, 1, 2,
      2, 1, 3,
    }

    verticies2 = [
      Core::Vertex.new(Vector3f.new(-field_width/10.0f32, 0, -field_depth/10.0f32), Vector2f.new(0, 0)),
      Core::Vertex.new(Vector3f.new(-field_width/10.0f32, 0, field_depth/10.0f32 * 3), Vector2f.new(0, 1)),
      Core::Vertex.new(Vector3f.new(field_width/10.0f32 * 3, 0, -field_depth/10.0f32), Vector2f.new(1, 0)),
      Core::Vertex.new(Vector3f.new(field_width/10.0f32 * 3, 0, field_depth/10.0f32 * 3), Vector2f.new(1, 1)),
    ]

    indicies2 = Array(LibGL::Int){
      0, 1, 2,
      2, 1, 3,
    }

    mesh2 = Core::Mesh.new(verticies2, indicies2, true)
    mesh = Core::Mesh.new(verticies, indicies, true)
    material = Core::Material.new
    material.add_texture("diffuse", Core::Texture.new(File.join(__DIR__, "./res/textures/defaultTexture.png")))
    # material.add_float("specularIntensity", 1)
    # material.add_float("specularPower", 8)

    material2 = Core::Material.new
    material2.add_texture("diffuse", Core::Texture.new(File.join(__DIR__, "./res/textures/defaultTexture.png")))
    # material2.add_float("specularIntensity", 1)
    # material2.add_float("specularPower", 8)

    monkey_file = File.join(__DIR__, "./res/models/", "monkey3.obj")

    temp_mesh = Core::Mesh.new(monkey_file)

    mesh_renderer = Common::Component::MeshRenderer.new(mesh, material)

    plane_object = Core::GameObject.new
    plane_object.add_component(mesh_renderer)
    plane_object.transform.pos.set(0, -1, 5)

    directional_light_object = Core::GameObject.new
    directional_light = Common::Light::DirectionalLight.new(Vector3f.new(0, 0, 1), 0.4)
    directional_light_object.add_component(directional_light)

    point_light_object = Core::GameObject.new
    point_light = Common::Light::PointLight.new(Vector3f.new(0.0f32, 1.0f32, 0.0f32), 0.4f32, Core::Attenuation.new(0.0f32, 0.0f32, 1.0f32))
    point_light_object.add_component(point_light)

    spot_light_object = Core::GameObject.new
    spot_light = Common::Light::SpotLight.new(
      Vector3f.new(0.0f32, 1.0f32, 1.0f32),
      0.4f32,
      Core::Attenuation.new(0.0f32, 0.0f32, 0.1f32),
      0.7f32)
    spot_light_object.add_component(spot_light)

    spot_light_object.transform.pos.set(5, 0, 5)
    spot_light_object.transform.rot = Quaternion.new(Vector3f.new(0.0f32, 1.0f32, 0.0f32), Prism::VMath.to_rad(90.0f32))

    add_object(plane_object)
    add_object(directional_light_object)
    add_object(point_light_object)
    add_object(spot_light_object)

    test_mesh1 = Core::GameObject.new.add_component(Common::Component::MeshRenderer.new(mesh2, material))
    test_mesh2 = Core::GameObject.new.add_component(Common::Component::MeshRenderer.new(mesh2, material))
    test_mesh3 = Core::GameObject.new.add_component(Common::Component::MeshRenderer.new(temp_mesh, material))

    test_mesh1.transform.pos.set(0f32, 2f32, 0f32)
    test_mesh1.transform.rot = Quaternion.new(Vector3f.new(0f32, 1f32, 0f32), 0.4f32)
    test_mesh2.transform.pos.set(0f32, 0f32, 5f32)

    test_mesh1.add_child(test_mesh2)

    test_mesh2.add_child(Common::Objects::GhostCamera.new)

    add_object(test_mesh1)
    add_object(test_mesh3)

    test_mesh3.transform.pos.set(5, 5, 5)
    test_mesh3.transform.rot.set(Quaternion.new(Vector3f.new(0, 1, 0), Prism::VMath.to_rad(-70)))

    add_object(Core::GameObject.new.add_component(Common::Component::MeshRenderer.new(Core::Mesh.new(monkey_file), material2)))

    directional_light.transform.rot = Quaternion.new(Vector3f.new(1f32, 0f32, 0f32), Prism::VMath.to_rad(-45f32))

    ambient_light = Prism::Core::Object.new
    ambient_light.add_component(Prism::Common::Light::AmbientLight.new(Vector3f.new(0.2, 0.2, 0.2)))
    add_object(ambient_light)
  end
end

Prism::ContextAdapter::GLFW.run("Model Demo", ModelDemo.new)
