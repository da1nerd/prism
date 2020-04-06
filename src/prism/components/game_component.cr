require "../core/transform"
require "../rendering/shader"
require "prism-core"

module Prism
  # The fundamental building block of the game.
  #
  # Components are the lights, material, meshes, etc.
  # that represent all the things in the game.
  # The `GameComponent` is added to a `GameObject`
  # which composes the scene graph.
  # These inherit the properties of their parent game object.
  abstract class GameComponent
    setter parent

    @parent : GameObject = GameObject.new

    def input(tick : Prism::Core::Tick, input : Prism::Core::Input)
    end

    def update(tick : Prism::Core::Tick)
    end

    # TODO: *rendering_engine* is deprecated
    def render(shader : Light, rendering_engine : RenderingEngine)
    end

    def add_to_engine(engine : RenderingEngine)
    end

    def transform : Transform
      @parent.transform
    end
  end
end
