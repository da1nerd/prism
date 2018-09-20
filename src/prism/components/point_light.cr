require "../../prism"

module Prism

  class PointLight < GameComponent

    getter base_light, position, atten, range
    setter base_light, position, atten, range

    def initialize(@base_light : BaseLight, @atten : Attenuation, @position : Vector3f, @range : Float32)
    end

    def add_to_rendering_engine(rendering_engine : RenderingEngine)
      rendering_engine.add_point_light(self)
    end

  end

end
