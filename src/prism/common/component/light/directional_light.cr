module Prism::Common::Light
  # Represents an external light source.
  # Sort of like the sun or moon. The source of the light is
  # not in the scene only the resulting rays.
  @[Core::Shader::Serializable::Options(name: "R_directionalLight")]
  class DirectionalLight < Core::Light
    include Core::Shader::Serializable

    # Creates a directional light with default values
    def initialize
      initialize(Vector3f.new(1, 1, 1), 0.8)
    end

    @[Core::Shader::Field]
    @base : BaseLight

    def initialize(color : Vector3f, intensity : Float32)
      super(Core::Shader::ShaderEngine.new("forward-directional"))
      @base = BaseLight.new(color, intensity)
    end

    @[Core::Shader::Field(key: "direction")]
    def direction : Prism::VMath::Vector3f
      return self.transform.get_transformed_rot.forward
    end
  end
end
