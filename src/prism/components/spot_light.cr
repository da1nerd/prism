require "./point_light"

module Prism
  class SpotLight < PointLight
    getter cutoff
    setter cutoff

    def initialize(color : Vector3f, intensity : Float32, attenuation : Vector3f, @cutoff : Float32)
      super(color, intensity, attenuation)
      self.shader = ForwardSpot.instance
    end

    def direction
      return self.transform.get_transformed_rot.forward
    end
  end
end
