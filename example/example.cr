require "../src/prism/**"

class BoxDemo < Prism::Core::GameEngine
  include Prism::Common
  alias Color = Prism::VMath::Vector3f

  def load_model(name : String)
    load_model(name) { |m| m }
  end

  # Loads a model from the resources and attaches it's material
  def load_model(name : String, &modify_material : Prism::Core::Material -> Prism::Core::Material) : Prism::Core::Entity
    material = Prism::Core::Material.new(File.join(__DIR__, "./res/textures/#{name}.png"))
    mesh = Prism::Core::Mesh.new(File.join(__DIR__, "./res/models/#{name}.obj"))
    material = modify_material.call(material)
    component = Component::MeshRenderer.new(mesh, material)
    object = Prism::Core::Entity.new.add_component(component)
  end

  # Loads a texture from the resources and returns it as a material
  def load_material(name : String)
    Prism::Core::Material.new(File.join(__DIR__, "./res/textures/#{name}.png"))
  end

  def init
    # Generate the terrain
    terrain_material = load_material("terrain")
    terrain_material.specular_intensity = 0.7f32
    terrain_material.specular_power = 10f32
    terrain = Objects::Terrain.new(0, 0, File.join(__DIR__, "./res/textures/heightmap.png"))
    terrain.material = terrain_material

    # Add a merchant stall
    stall = load_model("stall")
    stall.move_north(65).move_east(55)
    stall.elevate_to(terrain.height_at(stall))

    # Add a fern
    fern = load_model("fern") do |m|
      m.specular_intensity = 0.5f32
      m.has_transparency = true
      # m.use_fake_lighting = true
      m
    end
    fern.move_north(50).move_east(40)
    fern.elevate_to(terrain.height_at(fern))

    # add a tree
    tree = load_model("lowPolyTree")
    tree.move_north(55).move_east(60)
    tree.elevate_to(terrain.height_at(tree))

    # add a lamp
    lamp = load_model("lamp")
    lamp.move_north(65).move_east(50)
    lamp.elevate_to(terrain.height_at(lamp))

    # attach light to lamp
    lamp_light = Prism::Core::Object.new
    lamp_light.add_component(Light::PointLight.new(Color.new(1, 1, 1), 5))
    lamp_light.elevate_by(11).move_south(5)
    # NOTE: Objects inheirt the parent's position, so the previous line is relative to `lamp`
    # lamp.add_object(lamp_light)

    # add some grass
    grass = load_model("grass") do |m|
      m.specular_intensity = 0.5f32
      m.has_transparency = true
      m.use_fake_lighting = true
      m
    end
    grass.move_north(50).move_east(45)
    grass.elevate_to(terrain.height_at(fern))

    # Add some sunlight
    sun_light = Prism::Core::Object.new
    sun_light.add_component(Light::DirectionalLight.new(Vector3f.new(1, 1, 1), 0.3))
    sun_light.transform.rot = Quaternion.new(Vector3f.new(1f32, 0f32, 0f32), Prism::VMath.to_rad(-80f32))

    # Add some ambient light
    ambient_light = Prism::Core::Object.new
    ambient_light.add_component(Light::AmbientLight.new(Color.new(0.2, 0.2, 0.2)))

    # Add a moveable camera
    camera = Objects::GhostCamera.new
    camera.move_north(30).move_east(30).elevate_to(20)
    camera.transform.look_at(stall)

    # add everything to the scene
    add_object(lamp)
    add_object(tree)
    add_object(fern)
    add_object(grass)
    add_object(terrain)
    add_object(ambient_light)
    add_object(sun_light)
    add_object(stall)
    add_object(camera)
  end
end

Prism::ContextAdapter::GLFW.run("Prism Demo", BoxDemo.new)
