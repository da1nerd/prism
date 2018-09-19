require "./texture"
require "./vector3f"

module Prism

  class Material

    getter texture, color, specular_intensity, specular_exponent
    setter texture, color, specular_intensity, specular_exponent

    def initialize(texture : Texture)
      initialize(texture, Vector3f.new(1,1,1))
    end

    def initialize(texture : Texture, color : Vector3f)
      initialize(texture, color, 2, 32)
    end

    def initialize(@texture : Texture, @color : Vector3f, @specular_intensity : Float32, @specular_exponent : Float32)
    end

  end

end
