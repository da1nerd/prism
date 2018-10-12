require "../core/transform"
require "../rendering/shader"

module Prism
  # The fundamental building block of the game.
  # Components are the lights, material, meshes, etc.
  # that represent all the things in the game.
  # The `GameComponent` is added to a `GameObject`
  # which composes the scene graph.
  abstract class GameComponent
    setter parent

    @parent : GameObject = GameObject.new

    def input(delta : Float32, input : Input)
    end

    def update(delta : Float32)
    end

    def render(shader : Shader, rendering_engine : RenderingEngineProtocol)
    end

    def add_to_engine(engine : CoreEngine)
    end

    def transform : Transform
      @parent.transform
    end
  end
end
