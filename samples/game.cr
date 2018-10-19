require "lib_gl"
require "../src/prism"
require "./look_at_component.cr"
require "./level_map.cr"
require "./player.cr"

include Prism

class TestGame < Prism::Game
  @level : LevelMap?

  def init
    level = LevelMap.new("level0.png", "WolfCollection.png")
    @level = level

    level1 = GameObject.new().add_component(level)
    add_object(level1)

    player = Player.new(Vector2f.new(7, 7))
    add_object(player)

    # TODO: move lighting into level
    directional_light_object = GameObject.new()
    directional_light = DirectionalLight.new(Vector3f.new(1,1,1), 0.4)
    directional_light_object.add_component(directional_light)
    directional_light.transform.rot = Quaternion.new(Vector3f.new(1f32, 0f32, 0f32), Prism.to_rad(-45f32))
    add_object(directional_light_object)
  end
end
