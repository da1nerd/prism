require "../../prism"

module Prism

  class DirectionalLight < GameComponent

    getter base, direction
    setter base

    def add_to_rendering_engine(rendering_engine : RenderingEngine)
      rendering_engine.add_directional_light(self)
    end

    def initialize(@base : BaseLight, @direction : Vector3f)
      @direction = @direction.normalized
    end

    def direction=(@direction : Vector3f)
      @direction = @direction.normalized
    end

  end

end
