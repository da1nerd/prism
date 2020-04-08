require "./base_light"

module Prism
  # Represents an external light source.
  # Sort of like the sun or moon. The source of the light is
  # not in the scene only the resulting rays.
  @[Shader::Serializable::Options(name: "R_directionalLight")]
  class DirectionalLight < Light
    SHADER_PATH = File.join(File.dirname(PROGRAM_NAME), "/res/shaders/", "forward-directional")
    include Shader::Serializable

    # Creates a directional light with default values
    def initialize
      initialize(Vector3f.new(1, 1, 1), 0.8)
    end

    @[Shader::Field]
    @base : BaseLight

    def initialize(color : Vector3f, intensity : Float32)
      super(Shader.new(SHADER_PATH))
      @base = BaseLight.new(color, intensity)
    end

    @[Shader::Field(key: "direction")]
    def direction : Prism::VMath::Vector3f
      return self.transform.get_transformed_rot.forward
    end
  end
end
