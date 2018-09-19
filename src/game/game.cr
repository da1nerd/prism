require "lib_gl"
require "../prism/core/input"
require "../prism/rendering/mesh"
require "../prism/rendering/vertex"
require "../prism/core/vector3f"
require "../prism/rendering/phong_shader"
require "../prism/rendering/basic_shader"
require "../prism/core/timer"
require "../prism/core/transform"
require "../prism/rendering/camera"
require "../prism/rendering/spot_light"

module Prism

  abstract class Game
    abstract def init
    abstract def input(input : Input)
    abstract def update
    abstract def render
  end

end
