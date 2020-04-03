require "./base_light"

module Prism
  # Represents an external light source.
  # Sort of like the sun or moon. The source of the light is
  # not in the scene only the resulting rays.
  @[Uniform::Serializable::Options(struct: "R_directionalLight")]
  class DirectionalLight < BaseLight
    include Uniform::Serializable

    # Creates a directional light with default values
    def initialize
      initialize(Vector3f.new(1, 1, 1), 0.8)
    end

    @[Uniform::Field]
    @base : BaseLight

    def initialize(color : Vector3f, intensity : Float32)
      super(color, intensity)
      @base = BaseLight.new(color, intensity)
      self.shader = Shader.new("forward-directional")
    end

    @[Uniform::Field(key: "direction")]
    def direction : Prism::Vector3f
      return self.transform.get_transformed_rot.forward
    end
  end
end
