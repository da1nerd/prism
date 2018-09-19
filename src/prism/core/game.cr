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
    abstract def init
    abstract def input(input : Input)
    abstract def update
    abstract def render
  end

end
