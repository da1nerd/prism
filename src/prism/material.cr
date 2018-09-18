require "./texture"
require "./vector3f"

module Prism

  class Material

    getter texture, color
    setter texture, color

    def initialize(@texture : Texture, @color : Vector3f)
    end

  end

end
