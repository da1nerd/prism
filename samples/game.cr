require "lib_gl"
require "../src/prism"
require "./look_at_component.cr"
require "./level.cr"
require "./player.cr"

include Prism

class TestGame < Prism::Game
  @level : Level?

  def init
    level = Level.new("level0.png", "WolfCollection.png")
    @level = level

    level1 = GameObject.new().add_component(level)
    add_object(level1)

    player = Player.new(Vector2f.new(7, 7))
    add_object(player)

    directional_light_object = GameObject.new()
    directional_light = DirectionalLight.new(Vector3f.new(1,1,1), 0.4)
    directional_light_object.add_component(directional_light)
    directional_light.transform.rot = Quaternion.new(Vector3f.new(1f32, 0f32, 0f32), Prism.to_rad(-45f32))
    add_object(directional_light_object)

    # cam = Camera.new(Prism.to_rad(70.0f32), 800f32/600f32, 0.01f32, 1000.0f32)
    # camera = GameObject.new().add_component(FreeLook.new(0.5)).add_component(FreeMove.new(10.0)).add_component(cam)
    # camera.transform.pos = Vector3f.new(level.width/2f32, 0.5f32, 5)
    # add_object(camera)
  end
end
