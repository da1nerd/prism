require "../../../light"

module Prism::Common::Light
  # Represents an external light source.
  # Sort of like the sun or moon. The source of the light is
  # not in the scene only the resulting rays.
  class DirectionalLight < Prism::Light
    # Creates a directional light with default values
    def initialize
      initialize(Vector3f.new(1, 1, 1), 0.8)
    end

    @[Prism::Shader::Field]
    @base : BaseLight

    def initialize(color : Vector3f, intensity : Float32)
      @base = BaseLight.new(color, intensity)
    end

    @[Prism::Shader::Field(name: "direction")]
    def direction : Prism::Maths::Vector3f
      return self.transform.get_transformed_rot.forward
    end
  end
end
