require "./base_light"

module Prism
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
