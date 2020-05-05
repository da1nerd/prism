module Prism
  # Coordinates of a texture.
  # Coordinates begin in the top left corner and move clockwise.
  # Each corner is labeled accordingly: top_left, top_right, bottom_right, bottom_left
  alias TextureCoords = NamedTuple(bottom_left: Vector2f, bottom_right: Vector2f, top_right: Vector2f, top_left: Vector2f)
end
