require "../src/prism/**"

class Demo < Prism::GameEngine
  alias Color = Prism::Maths::Vector3f

  def load_model(name : String)
    load_model(name) { |m| m }
  end

  # Loads a model from the resources and attaches it's material
  def load_model(name : String, &modify_material : Prism::Material -> Prism::Material) : Prism::Entity
    material = Prism::Material.new(File.join(__DIR__, "./res/textures/#{name}.png"))
    mesh = Prism::Mesh.new(File.join(__DIR__, "./res/models/#{name}.obj"))
    material = modify_material.call(material)
    object = Prism::Entity.new
    object.name = name
    # add components to entity
    object.add mesh
    object.add material
    object.add object.transform
    object
  end

  def create_entity(*components : Crash::Component) : Prism::Entity
    entity = Prism::Entity.new
    components.each do |comp|
      entity.add comp
    end
    entity.add entity.transform
    add_entity entity
    entity
  end

  # Loads a texture from the resources and returns it as a material
  def load_material(name : String)
    Prism::Material.new(File.join(__DIR__, "./res/textures/#{name}.png"))
  end

  def init
    # Generate the terrain
    terrain_material = load_material("terrain")
    terrain_material.specular_intensity = 0.7f32
    terrain_material.specular_power = 10f32
    terrain = Prism::Terrain.new(0, 0, File.join(__DIR__, "./res/textures/heightmap.png"))
    terrain.material = terrain_material
    terrain.add terrain_material
    terrain.add terrain.transform
    terrain.add terrain.mesh.as(Prism::Mesh)

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
    tree.get(Prism::Material).as(Prism::Material).wire_frame = true

    # add a lamp
    lamp = load_model("lamp")
    lamp.move_north(65).move_east(50)
    lamp.elevate_to(terrain.height_at(lamp))

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
    sun_light = Prism::Entity.new
    sun_light.add_component(Prism::DirectionalLight.new(Vector3f.new(1, 1, 1), 0.8))
    sun_light.transform.rot = Quaternion.new(Vector3f.new(1f32, 0f32, 0f32), Prism::Maths.to_rad(-80f32))
    sun_light.name = "sun"

    # Add a moveable camera
    camera = Prism::GhostCamera.new
    camera.name = "camera"
    camera.add camera.transform
    camera.move_north(30).move_east(30).elevate_to(20)
    camera.transform.look_at(stall)

    # add everything to the scene
    add_object(lamp)
    add_object(tree)
    add_object(fern)
    add_object(grass)
    add_object(terrain)
    add_object(sun_light)
    add_object(stall)
    add_object(camera)
  end
end

Prism::Adapter::GLFW.run("Prism Demo", Demo.new)
