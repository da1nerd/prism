require "./base_light"

module Prism
  # Represents a point light.
  # That is, light that radiates out from a point.
  @[Uniform::Serializable::Options(struct: "R_pointLight")]
  class PointLight < BaseLight
    COLOR_DEPTH = 256.0f32

    include Uniform::Serializable
    property range
    getter attenuation

    @[Uniform::Field]
    @base : BaseLight
    @[Uniform::Field]
    @range : Float32
    @[Uniform::Field(key: "atten")]
    @attenuation : Attenuation

    @[Uniform::Field]
    def position : Prism::Vector3f
      self.transform.get_transformed_pos
    end

    def initialize
      initialize(Vector3f.new(1, 0, 0), 0.5, Attenuation.new(0.0f32, 0.0f32, 1.0f32))
    end

    def initialize(color : Vector3f)
      initialize(color, 0.5, Attenuation.new(0.0f32, 0.0f32, 1.0f32))
    end

    def initialize(color : Vector3f, intensity : Float32, @attenuation : Attenuation)
      super(color, intensity)
      @base = BaseLight.new(color, intensity)

      a = @attenuation.exponent
      b = @attenuation.linear
      c = @attenuation.constant - COLOR_DEPTH * intensity * color.max

      @range = (-b + Math.sqrt(b * b - 4.0f32 * a * c)) / (2.0f32 * a)

      self.shader = Shader.new("forward-point")
    end
  end
end
