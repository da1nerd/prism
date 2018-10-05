require "./point_light"

module Prism

  class SpotLight < PointLight

    getter direction, cutoff
    setter cutoff

    def initialize(color : Vector3f, intensity : Float32, attenuation : Vector3f, position : Vector3f, range : Float32, @direction : Vector3f, @cutoff : Float32)
      super(color, intensity, attenuation, position, range)
      @direction = @direction.normalized

      self.shader = ForwardSpot.instance
    end

    def direction=(@direction : Vector3f)
      @direction = @direction.normalized
    end

  end

end
