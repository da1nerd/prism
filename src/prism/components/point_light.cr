require "./game_component"
require "./base_light"
require "../rendering/attenuation"

module Prism

  class PointLight < BaseLight

    getter position, atten, range
    setter position, atten, range

    def initialize(color : Vector3f, intensity : Float32, @atten : Attenuation, @position : Vector3f, @range : Float32)
      super(color, intensity)

      self.shader = ForwardPoint.instance
    end

  end

end
