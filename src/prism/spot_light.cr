module Prism

  class SpotLight

    getter point_light, direction, cutoff
    setter point_light, cutoff

    def initialize(@point_light : PointLight, @direction : Vector3f, @cutoff : Float32)
      @direction = @direction.normalized
    end

    def direction=(@direction : Vector3f)
      @direction = @direction.normalized
    end

  end

end
