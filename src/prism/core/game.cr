require "lib_gl"
require "./input"
require "../rendering/mesh"
require "../rendering/vertex"
require "./vector3f"
require "../rendering/phong_shader"
require "../rendering/basic_shader"
require "./timer"
require "./transform"
require "../rendering/camera"
require "../rendering/spot_light"

module Prism

  abstract class Game

    @root : GameObject = GameObject.new

    abstract def init

    def input(delta : Float32, input : Input)
      get_root_object.input(delta)
    end

    def update(delta : Float32)
      get_root_object.update(delta)
    end

    def get_root_object : GameObject
      @root
    end
  end

end
