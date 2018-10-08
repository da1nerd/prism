require "./base_light"

module Prism

  class DirectionalLight < BaseLight

    def initialize(color : Vector3f, intensity : Float32)
      super(color, intensity)

      self.shader = ForwardDirectional.instance
    end

    def direction
      return self.transform.rot.forward
    end

  end

end
