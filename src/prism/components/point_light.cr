require "./base_light"

module Prism
  class PointLight < BaseLight
    COLOR_DEPTH = 256.0f32

    @range : Float32

    getter range
    setter range

    def initialize(color : Vector3f, intensity : Float32, @attenuation : Vector3f)
      super(color, intensity)

      a = @attenuation.z
      b = @attenuation.y
      c = @attenuation.x - COLOR_DEPTH * intensity * color.max

      @range = (-b + Math.sqrt(b * b - 4.0f32 * a * c)) / (2.0f32 * a)

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
