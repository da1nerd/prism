require "./base_light"
require "./attenuation"
require "../core/vector3f"

module Prism

  class PointLight

    getter base_light, position, atten, range
    setter base_light, position, atten, range

    def initialize(@base_light : BaseLight, @atten : Attenuation, @position : Vector3f, @range : Float32)
    end

  end

end
