require "lib_gl"
require "../src/prism"
require "./look_at_component.cr"
require "./level.cr"

include Prism

class TestGame < Prism::Game
  @level : Level?
  @level_num : Int32 = 0
  @wrapper : GameObject = GameObject.new

  def init
    ambient_light = Prism::Object.new
    ambient_light.add_component(Prism::AmbientLight.new(Prism::Vector3f.new(0.5, 0.5, 0.5)))
    add_object(ambient_light);

    # TODO: move lighting into level
    directional_light_object = GameObject.new()
    directional_light = DirectionalLight.new(Vector3f.new(1,1,1), 0.9)
    directional_light_object.add_component(directional_light)
    directional_light.transform.rot = Quaternion.new(Vector3f.new(1f32, 0f32, 0f32), Prism.to_rad(-45f32))
    add_object(directional_light_object)

    add_object(@wrapper)

    load_next_level
  end

  def get_level
    if level = @level
      level
    else
      puts "You did not load a level in the game"
      exit 1
    end
  end

  def load_next_level
    # TODO: this releases the mouse when we destroy the player. It would be nice to keep the mouse locked.
    @level_num += 1
    level = Level.new("level#{@level_num}.png", "WolfCollection.png", self)
    @wrapper.add_object(level)
    # remove previous level
    if l = @level
      @wrapper.remove_object(l)
    end
    @level = level
  end
end
