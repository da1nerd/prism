require "../../prism"

module Prism

  abstract class GameComponent

    def input(transform : Transform, delta : Float32)
    end

    def update(transform : Transform, delta : Float32)
    end

    def render(transform : Transform, shader : Shader)
    end

    def add_to_rendering_engine(rendering_engine : RenderingEngine)
    end

  end

end
