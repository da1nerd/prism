require "./base_light"

module Prism
  # Represents an external light source.
  # Sort of like the sun or moon. The source of the light is
  # not in the scene only the resulting rays.
  class DirectionalLight < BaseLight
    def initialize(color : Vector3f, intensity : Float32)
      super(color, intensity)

      self.shader = Shader.new("forward-directional")
    end

    def direction
      return self.transform.get_transformed_rot.forward
    end
  end
end
