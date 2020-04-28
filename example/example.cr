require "../src/prism/**"

class Demo < Prism::GameEngine
  alias Color = Prism::Maths::Vector3f

  def load_entity(name : String)
    load_entity(name) { |m| m }
  end

  # Loads a texture from the resources and returns it as a material
  def load_material(name : String)
    Prism::Material.new(File.join(__DIR__, "./res/textures/#{name}.png"))
  end

  def load_model(name : String) : Prism::TexturedModel
    material = load_material(name)
    mesh = Prism::Mesh.new(File.join(__DIR__, "./res/models/#{name}.obj"))
    Prism::TexturedModel.new(mesh, material)
  end

  # Loads a model from the resources and attaches it's material
  def load_entity(name : String, &modify_material : Prism::Material -> Prism::Material) : Prism::Entity
    model = load_model(name)
    model.material = modify_material.call(model.material)
    object = Prism::Entity.new
    object.name = name
    object.add model
    object
  end

  # Seeds the game with some objects
  def seed(name : String, terrain : Prism::Terrain, scale : Float32)
    model = load_model(name)
    random = Random.new
    0.upto(100) do |i|
      x : Float32 = random.next_float.to_f32 * 800 # the terrain is 800x800
      z : Float32 = random.next_float.to_f32 * 800

      y : Float32 = terrain.height_at(x, z)
      e = Prism::Entity.new
      e.add model
      transform = Prism::Transform.new(x, y, z)
      transform.scale((random.next_float.to_f32 + 0.5) * scale)
      e.add transform
      add_entity e
    end
  end

  def init
    # Generate the terrain
    terrain_material = load_material("terrain")
    terrain_material.specular_intensity = 0.7f32
    terrain_material.specular_power = 10f32
    terrain = Prism::Terrain.new(0, 0, File.join(__DIR__, "./res/textures/heightmap.png"))
    terrain.add Prism::TexturedModel.new(terrain.mesh.as(Prism::Mesh), terrain_material)

    # Add a merchant stall
    stall = load_entity("stall")
    stall.get(Prism::Transform).as(Prism::Transform).move_north(65).move_east(55).elevate_to(terrain.height_at(stall))

    # Add a fern
    fern = load_entity("fern") do |m|
      m.specular_intensity = 0.5f32
      m.has_transparency = true
      m
    end
    fern.get(Prism::Transform).as(Prism::Transform).move_north(50).move_east(40).elevate_to(terrain.height_at(fern))

    # add a tree
    tree = load_entity("lowPolyTree")
    tree.get(Prism::Transform).as(Prism::Transform).move_north(55).move_east(60).elevate_to(terrain.height_at(tree))
    tree.get(Prism::TexturedModel).as(Prism::TexturedModel).material.wire_frame = true

    # add a lamp
    lamp = load_entity("lamp")
    lamp.get(Prism::Transform).as(Prism::Transform).move_north(65).move_east(50).elevate_to(terrain.height_at(lamp))

    # add some grass
    grass = load_entity("grass") do |m|
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

    # Generate a bunch of random trees
    seed("tree", terrain, 8)

    # Generate a bunch of random ferns
    seed("fern", terrain, 1)

    # Generate a bunch of random cubes to test performance
    # cube_model = Prism::TexturedModel.new(Prism::Mesh.cube(2), Prism::Material.new)
    # random = Random.new
    # 0.upto(1000) do |i|
    #   x : Float32 = random.next_float.to_f32 * 800
    #   y : Float32 = random.next_float.to_f32 * 100
    #   z : Float32 = random.next_float.to_f32 * 800
    #   e = Prism::Entity.new
    #   e.add cube_model
    #   e.add Prism::Transform.new(x, y, z)
    #   add_entity e
    # end

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
