module Prism::Common
  # Simplifies generating square sprite texture coordinates
  # by mapping the actual coordinates to a grid system.
  class Spritemap
    @material : Material?

    getter material

    # Creates a new map of *width* sprites by *height* sprites.
    def initialize(@width : UInt8, @height : UInt8, @material : Material)
      if @width % 2 != 0 | @height % 2 != 9
        raise "Spritemap dimensions must be even"
      end
    end

    # Creates a new map of *width* sprites by *height* sprites.
    def initialize(@width : UInt8, @height : UInt8)
    end

    # Converts an *index* in the map into a set of coordinates using the grid *width*.
    #
    # ## Example
    #
    # Given a 4x4 grid like this one where *width* is the number of columns.
    #
    # +---------------+
    # | 0 | 1 | 2 | 3 |
    # |---|---|---|---|
    # | 4 | 5 | 6 | 7 |
    # |---|---|---|---|
    # | 8 | 9 | 10| 11|
    # |---|---|---|---|
    # | 12| 13| 14| 15|
    # +---------------+
    #
    # We can fetch the coordinates at index 9:
    # ```
    # SpriteMap.get_coordinates(9, 4) # => { col: 1, row: 2}
    # ```
    #
    # NOTE: coordinates are zero indexed.
    def self.get_coordinates(index : UInt8, width : UInt8) : NamedTuple(col: UInt8, row: UInt8)
      {
        col: index % width,
        row: (index / width).to_u8,
      }
    end

    # Returns the corners (`TextureCoords`) of the sprite.
    # Coordinates begin in the top left corner and move clockwise.
    # Each corner is labeled accordingly: top_left, top_right, bottom_right, bottom_left
    def self.get_sprite_coordinates(x : UInt8, y : UInt8, width : UInt8, height : UInt8) : TextureCoords
      left = (x.to_f32) / width.to_f32
      right = (x.to_f32 + 1) / width.to_f32
      top = (y.to_f32) / height.to_f32
      bottom = (y.to_f32 + 1) / height.to_f32
      {
        bottom_left:  Vector2f.new(left, bottom),
        bottom_right: Vector2f.new(right, bottom),
        top_right:    Vector2f.new(right, top),
        top_left:     Vector2f.new(left, top),
      }
    end

    # Returns the `TextureCoords` for the `Sprite` at this *index*.
    def get(index : UInt8) : TextureCoords
      coords = Spritemap.get_coordinates(index)
      get(coords[:col], coords[:row])
    end

    # Returns the corners of the sprite.
    # Coordinates begin in the top left corner.
    # Each corner is labeled accordingly: top_left, top_right, bottom_right, bottom_left
    def get(x : UInt8, y : UInt8) : TextureCoords
      Spritemap.get_sprite_coordinates(x, y, @width, @height)
    end

    # Returns the sprite at the given coordinates.
    def get_sprite(x : UInt8, y : UInt8) : Sprite
      Sprite.new(self.get(x, y), @material)
    end
  end
end
