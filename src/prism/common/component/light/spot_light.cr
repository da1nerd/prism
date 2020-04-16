module Prism::Common::Light
  # Represents a spot light
  @[Core::Shader::Serializable::Options(name: "R_spotLight")]
  class SpotLight < Core::Light
    include Core::Shader::Serializable
    property cutoff

    @[Core::Shader::Field(key: "cutoff")]
    @cutoff : Float32

    @[Core::Shader::Field(key: "pointLight")]
    @point_light : PointLight

    def initialize
      initialize(Vector3f.new(1, 1, 1), 1, Core::Attenuation.new(0.0f32, 0.0f32, 1f32), 0.5)
    end

    def initialize(color : Vector3f)
      initialize(color, 1, Core::Attenuation.new(0.0f32, 0.0f32, 0.1f32), 0.8)
    end

    def initialize(color : Vector3f, intensity : Float32, attenuation : Core::Attenuation, @cutoff : Float32)
      super(Core::Shader::ShaderProgram.new("forward-spot"))
      @point_light = PointLight.new(color, intensity, attenuation)
    end

    @[Override]
    def update(tick : RenderLoop::Tick)
      @point_light.transform.parent = transform
    end

    @[Core::Shader::Field]
    def direction : Prism::VMath::Vector3f
      return self.transform.get_transformed_rot.forward
    end
  end
end
