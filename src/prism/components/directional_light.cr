require "./base_light"

module Prism
  # Represents an external light source.
  # Sort of like the sun or moon. The source of the light is
  # not in the scene only the resulting rays.
  class DirectionalLight < BaseLight
    include Uniform::Serializable

    # Creates a directional light with default values
    def initialize
      initialize(Vector3f.new(1, 1, 1), 0.8)
    end

    def initialize(color : Vector3f, intensity : Float32)
      super(color, intensity)

      self.shader = Shader.new("forward-directional")
    end

    # @[Uniform::Field(struct: "DirectionalLight", key: "direction")]
    def direction
      return self.transform.get_transformed_rot.forward
    end
  end
end
