require "./base_light"
require "./attenuation"
require "./vector3f"

module Prism

  class PointLight

    getter base_light, position, atten
    setter base_light, position, atten

    def initialize(@base_light : BaseLight, @atten : Attenuation, @position : Vector3f)
    end

  end

end
