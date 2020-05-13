module Prism
  # Represents a point light.
  # That is, light that radiates out from a point.
  class PointLight < Prism::Light
    COLOR_DEPTH   = 256.0f32
    DEFAULT_ATTEN = Prism::Attenuation.new(1.0f32, 0.001f32, 0.002f32)

    property range
    getter attenuation

    @[Field]
    @base : BaseLight
    @[Field]
    @range : Float32
    @[Field(name: "atten")]
    @attenuation : Prism::Attenuation

    def initialize
      initialize(Vector3f.new(1, 1, 1), 2, DEFAULT_ATTEN)
    end

    def initialize(color : Vector3f)
      initialize(color, 2, DEFAULT_ATTEN)
    end

    def initialize(color : Vector3f, intensity : Float32)
      initialize(color, intensity, DEFAULT_ATTEN)
    end

    def initialize(color : Vector3f, intensity : Float32, @attenuation : Prism::Attenuation)
      @base = BaseLight.new(color, intensity)

      a = @attenuation.exponent
      b = @attenuation.linear
      c = @attenuation.constant - COLOR_DEPTH * intensity * color.max

      @range = (-b + Math.sqrt(b * b - 4.0f32 * a * c)) / (2.0f32 * a)
    end
  end
end
