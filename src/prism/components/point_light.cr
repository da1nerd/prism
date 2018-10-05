require "./game_component"
require "./base_light"
require "../rendering/attenuation"

module Prism

  class PointLight < GameComponent

    getter base_light, position, atten, range
    setter base_light, position, atten, range

    def initialize(@base_light : BaseLight, @atten : Attenuation, @position : Vector3f, @range : Float32)
    end

  end

end
