require "./point_light"

module Prism
  # Represents a spot light
  class SpotLight < PointLight
    getter cutoff
    setter cutoff

    def initialize(color : Vector3f, intensity : Float32, attenuation : Attenuation, @cutoff : Float32)
      super(color, intensity, attenuation)
      self.shader = Shader.new("forward-spot")
    end

    def direction
      return self.transform.get_transformed_rot.forward
    end
  end
end
