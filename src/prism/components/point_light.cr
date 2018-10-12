require "./base_light"

module Prism
  # Represents a point light.
  # That is, light that radiates out from a point.
  class PointLight < BaseLight
    COLOR_DEPTH = 256.0f32

    @range : Float32

    getter range, attenuation
    setter range

    def initialize(color : Vector3f, intensity : Float32, @attenuation : Attenuation)
      super(color, intensity)

      a = @attenuation.exponent
      b = @attenuation.linear
      c = @attenuation.constant - COLOR_DEPTH * intensity * color.max

      @range = (-b + Math.sqrt(b * b - 4.0f32 * a * c)) / (2.0f32 * a)

      self.shader = Shader.new("forward-point")
    end
  end
end
