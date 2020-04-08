require "./base_light"

module Prism
  # Represents a point light.
  # That is, light that radiates out from a point.
  @[Shader::Serializable::Options(name: "R_pointLight")]
  class PointLight < Light
    SHADER_PATH = File.join(File.dirname(PROGRAM_NAME), "/res/shaders/", "forward-point")
    COLOR_DEPTH = 256.0f32

    include Shader::Serializable
    property range
    getter attenuation

    @[Shader::Field]
    @base : BaseLight
    @[Shader::Field]
    @range : Float32
    @[Shader::Field(key: "atten")]
    @attenuation : Attenuation

    @[Shader::Field]
    def position : Prism::VMath::Vector3f
      self.transform.get_transformed_pos
    end

    def initialize
      initialize(Vector3f.new(1, 0, 0), 0.5, Attenuation.new(0.0f32, 0.0f32, 1.0f32))
    end

    def initialize(color : Vector3f)
      initialize(color, 0.5, Attenuation.new(0.0f32, 0.0f32, 1.0f32))
    end

    def initialize(color : Vector3f, intensity : Float32, @attenuation : Attenuation)
      super(Shader.new(SHADER_PATH))
      @base = BaseLight.new(color, intensity)

      a = @attenuation.exponent
      b = @attenuation.linear
      c = @attenuation.constant - COLOR_DEPTH * intensity * color.max

      @range = (-b + Math.sqrt(b * b - 4.0f32 * a * c)) / (2.0f32 * a)
    end
  end
end
