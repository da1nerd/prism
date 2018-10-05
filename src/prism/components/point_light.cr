require "./base_light"

module Prism

  class PointLight < BaseLight

    getter range
    setter range

    def initialize(color : Vector3f, intensity : Float32, @attenuation : Vector3f)
      super(color, intensity)
      @range = 1_000.0f32 # TODO: calculate
      self.shader = ForwardPoint.instance
    end

    def constant
      @attenuation.x
    end

    def linear
      @attenuation.y
    end

    def exponent
      @attenuation.z
    end

    def constant=(constant : Float32)
      @attenuation.x = constant
    end

    def linear=(linear : Float32)
      @attenuation.y = linear
    end

    def exponent=(exponent : Float32)
      @attenuation.z = exponent
    end
  end

end
