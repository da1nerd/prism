module Prism
  # Represents a set of coordinates within the texture.
  class Sprite
    getter coords, texture

    def initialize(@coords : TextureCoords, @texture : Prism::Texture)
    end
  end
end
