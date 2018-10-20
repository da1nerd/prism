require "lib_gl"
require "../src/prism"
require "./look_at_component.cr"
require "./level.cr"

include Prism

class TestGame < Prism::Game
  @level : Level?

  def init
    level = Level.new("level0.png", "WolfCollection.png")
    @level = level
    add_object(level)

    # TODO: move lighting into level
    directional_light_object = GameObject.new()
    directional_light = DirectionalLight.new(Vector3f.new(1,1,1), 0.4)
    directional_light_object.add_component(directional_light)
    directional_light.transform.rot = Quaternion.new(Vector3f.new(1f32, 0f32, 0f32), Prism.to_rad(-45f32))
    add_object(directional_light_object)
  end
end
