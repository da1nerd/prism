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
    object.add Prism::TexturedModel.new(mesh, material)
    object
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
    terrain.add Prism::TexturedModel.new(terrain.mesh.as(Prism::Mesh), terrain_material)

    # Add a merchant stall
    stall = load_model("stall")
    stall.get(Prism::Transform).as(Prism::Transform).move_north(65).move_east(55).elevate_to(terrain.height_at(stall))

    # Add a fern
    fern = load_model("fern") do |m|
      m.specular_intensity = 0.5f32
      m.has_transparency = true
      m
    end
    fern.get(Prism::Transform).as(Prism::Transform).move_north(50).move_east(40).elevate_to(terrain.height_at(fern))

    # add a tree
    tree = load_model("lowPolyTree")
    tree.get(Prism::Transform).as(Prism::Transform).move_north(55).move_east(60).elevate_to(terrain.height_at(tree))
    tree.get(Prism::TexturedModel).as(Prism::TexturedModel).material.wire_frame = true

    # add a lamp
    lamp = load_model("lamp")
    lamp.get(Prism::Transform).as(Prism::Transform).move_north(65).move_east(50).elevate_to(terrain.height_at(lamp))

    # add some grass
    grass = load_model("grass") do |m|
      m.specular_intensity = 0.5f32
      m.has_transparency = true
      m.use_fake_lighting = true
      m
    end
    grass.get(Prism::Transform).as(Prism::Transform).move_north(50).move_east(45).elevate_to(terrain.height_at(fern))

    # Add some sunlight
    sun_light = Prism::Entity.new
    sun_light.add Prism::DirectionalLight.new(Vector3f.new(1, 1, 1), 0.8)
    light_transform = Prism::Transform.new
    light_transform.rot = Quaternion.new(Vector3f.new(1f32, 0f32, 0f32), Prism::Maths.to_rad(-80f32))
    sun_light.add light_transform
    sun_light.name = "sun"

    # Add a moveable camera
    camera = Prism::GhostCamera.new
    camera.name = "camera"
    camera.add Prism::Transform.new.look_at(stall).move_north(30).move_east(30).elevate_to(20)

    # Generate a bunch of random cubes to test performance
    cube_model = Prism::TexturedModel.new(Prism::Mesh.cube(2), Prism::Material.new)
    random = Random.new
    0.upto(3000) do |i|
      x : Float32 = random.next_float.to_f32 * 800
      y : Float32 = random.next_float.to_f32 * 100
      z : Float32 = random.next_float.to_f32 * 800
      e = Prism::Entity.new
      e.add cube_model
      e.add Prism::Transform.new(x, y, z)
      add_entity e
    end

    # add everything to the scene
    add_entity(lamp)
    add_entity(tree)
    add_entity(fern)
    add_entity(grass)
    add_entity(terrain)
    add_entity(sun_light)
    add_entity(stall)
    add_entity(camera)
  end
end

Prism::Adapter::GLFW.run("Prism Demo", Demo.new)
