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

    def input(input : Input)
      get_root_object.input
    end

    def update
      get_root_object.update
    end

    def render
      get_root_object.render
    end

    def get_root_object : GameObject
      @root
    end
  end

end
