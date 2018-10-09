require "../core/transform"
require "../rendering/shader"
require "../rendering/rendering_engine_protocol"

module Prism

  abstract class GameComponent

    setter parent

    @parent : GameObject = GameObject.new

    def input(delta : Float32, input : Input)
    end

    def update(delta : Float32)
    end

    def render(shader : Shader, rendering_engine : RenderingEngineProtocol)
    end

    def add_to_rendering_engine(rendering_engine : RenderingEngineProtocol)
    end

    def transform : Transform
      @parent.transform
    end
  end

end
