module Prism::Common
  alias SpriteCoords = NamedTuple(bottom_left: Vector2f, bottom_right: Vector2f, top_right: Vector2f, top_left: Vector2f)

  # Represents a set of coordinates within the material.
  class Sprite
    getter coords, material

    def initialize(@coords : SpriteCoords, @material : Material)
    end
  end
end
