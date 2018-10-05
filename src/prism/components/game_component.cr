require "../core/transform"
require "../rendering/shader"

module Prism

  abstract class GameComponent

    setter parent

    @parent : GameObject = GameObject.new

    def input(delta : Float32)
    end

    def update(delta : Float32)
    end

    def render(shader : Shader)
    end

    def add_to_rendering_engine(rendering_engine : RenderingEngine)
    end

    def transform : Transform
      @parent.transform
    end
  end

end
