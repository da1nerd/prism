module Prism::Common
  # Represents a set of coordinates within the material.
  class Sprite
    getter coords, material

    def initialize(@coords : TextureCoords, @material : Material)
    end
  end
end
