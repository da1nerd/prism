require "./base_light"

module Prism

  class DirectionalLight < BaseLight

    getter direction

    def initialize(color : Vector3f, intensity : Float32, @direction : Vector3f)
      super(color, intensity)
      @direction = @direction.normalized

      self.shader = ForwardDirectional.instance
    end

    def direction=(@direction : Vector3f)
      @direction = @direction.normalized
    end

  end

end
