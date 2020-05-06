require "../src/prism/**"

class Demo < Prism::GameEngine
  alias Color = Prism::Maths::Vector3f

  def load_entity(name : String)
    load_entity(name) do
    end
  end

  # Loads a texture from the resources
  def load_texture(name : String)
    # simple hack to load fern atlas
    if name == "fern"
      Prism::Texture.new(File.join(__DIR__, "./res/textures/#{name}.png"), 2)
    else
      Prism::Texture.new(File.join(__DIR__, "./res/textures/#{name}.png"))
    end
  end

  # Loads a model from the resources and attaches it's material
  def load_model(name : String) : Prism::TexturedModel
    texture = load_texture(name)
    mesh = Prism::Model.load(File.join(__DIR__, "./res/models/#{name}.obj"))
    texture_pack = Prism::TexturePack.new
    texture_pack.add "diffuse", texture
    Prism::TexturedModel.new(mesh, texture_pack)
  end

  # Generates a new entity with a model and textures
  # You can optionally provide a material
  def load_entity(name : String, &modify_material : -> Prism::Material | Nil) : Prism::Entity
    model = load_model(name)
    material = modify_material.call
    object = Prism::Entity.new
    object.name = name
    object.add model
    if material
      object.add material.as(Prism::Material)
    else
      object.add Prism::Material.new
    end
    object
  end

  def seed(name : String, terrain : Prism::TerrainEntity, scale : Float32)
    seed(name, terrain, scale) do
    end
  end

  # Seeds the game with some objects
  def seed(name : String, terrain : Prism::TerrainEntity, scale : Float32, &modify_material : -> Prism::Material | Nil)
    model = load_model(name)
    material = modify_material.call
    random = Random.new
    0.upto(200) do |i|
      x : Float32 = random.next_float.to_f32 * 800 # the terrain is 800x800
      z : Float32 = random.next_float.to_f32 * 800

      y : Float32 = terrain.terrain.height_at(x, z)
      e = Prism::Entity.new
      e.add model
      if material
        e.add material.as(Prism::Material)
      else
        e.add Prism::Material.new
      end
      transform = Prism::Transform.new(x, y, z)
      transform.scale((random.next_float.to_f32 + 0.5) * scale)
      e.add transform
      # hack to load fern texture atlas
      if name === "fern"
        e.add Prism::TextureAtlasIndex.new(rand(4).to_u32)
      end
      add_entity e
    end
  end

  def init
    # Generate the terrain
    texture_pack = Prism::TerrainTexturePack.new(
      background: Prism::Texture.new(File.join(__DIR__, "./res/textures/grassy2.png")),
      blend_map: Prism::Texture.new(File.join(__DIR__, "./res/textures/blendMap.png")),
      red: Prism::Texture.new(File.join(__DIR__, "./res/textures/mud.png")),
      green: Prism::Texture.new(File.join(__DIR__, "./res/textures/grassFlowers.png")),
      blue: Prism::Texture.new(File.join(__DIR__, "./res/textures/path.png"))
    )
    terrain = Prism::ModelData.terrain(0, 0, File.join(__DIR__, "./res/textures/heightmap.png"), texture_pack)
    add_entity terrain

    # Add a merchant stall
    stall = load_entity("stall")
    stall.get(Prism::Transform).as(Prism::Transform).move_north(65).move_east(55).elevate_to(terrain.terrain.height_at(stall))
    add_entity stall

    # add a tree
    tree = load_entity("lowPolyTree")
    tree.get(Prism::Transform).as(Prism::Transform).move_north(55).move_east(60).elevate_to(terrain.terrain.height_at(tree))
    tree.get(Prism::TexturedModel).as(Prism::TexturedModel)
    tree_material = Prism::Material.new
    tree_material.wire_frame = true
    tree.add tree_material
    add_entity tree

    # add a lamp
    lamp = load_entity("lamp")
    lamp.get(Prism::Transform).as(Prism::Transform).move_north(65).move_east(50).elevate_to(terrain.terrain.height_at(lamp))
    add_entity lamp

    # Add some sunlight
    sun_light = Prism::Entity.new
    sun_light.add Prism::DirectionalLight.new(Vector3f.new(1, 1, 1), 0.8)
    light_transform = Prism::Transform.new
    light_transform.rot = Quaternion.new(Vector3f.new(1f32, 0f32, 0f32), Prism::Maths.to_rad(-80f32))
    sun_light.add light_transform
    add_entity sun_light

    # Generate a bunch of random trees
    seed("tree", terrain, 8)

    # Generate a bunch of random ferns
    seed("fern", terrain, 1) do
      m = Prism::Material.new
      m.specular_intensity = 0.5f32
      m.has_transparency = true
      m
    end

    person = Prism::Entity.new
    person.add load_model("person")
    person.add Prism::Material.new
    person.add Prism::PlayerMovement.new
    person.add Prism::InputSubscriber.new
    # Disable this for first person view
    person.add Prism::ThirdPersonCameraControls.new
    person.get(Prism::Transform).as(Prism::Transform).move_north(32).move_east(32).elevate_to(20)
    person.add Prism::Camera.new
    add_entity person

    gui_entity = Prism::Entity.new
    gui_entity.add Prism::GUITexture.new(load_texture("health"), Vector2f.new(-0.75, 0.95), Vector2f.new(0.25, 0.25))
    add_entity gui_entity

    # Enable this (and disable the person above) to enable a free flying camera
    # camera = Prism::GhostCamera.new
    # camera.add Prism::Transform.new.look_at(stall).move_north(30).move_east(30).elevate_to(20)
    # add_entity camera

    # Generate a bunch of random cubes to test performance
    # random = Random.new
    # 0.upto(1000) do |i|
    #   x : Float32 = random.next_float.to_f32 * 800
    #   y : Float32 = random.next_float.to_f32 * 100
    #   z : Float32 = random.next_float.to_f32 * 800
    #   e = Prism::Entity.new
    #   e.add cube_model
    #   e.add Prism::Material.new
    #   e.add Prism::Transform.new(x, y, z)
    #   add_entity e
    # end
  end
end

Prism::Adapter::GLFW.run("Prism Demo", Demo.new)
