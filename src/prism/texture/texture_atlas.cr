module Prism
  struct TextureAtlas

    @size : UInt32
    getter size

    # Creates an atlas with a default size of 1.
    # This will produces coordinates for a regular texture that is not an atlas.
    def initialize
      @size = 1
    end

    # Produces an atlas for retrieving texture coordinates.
    #
    # The *size* determins the number of columns and rows in the atlas.
    #
    # ## Example
    #
    # A *size* of 4 will produces a 4x4 atlas.
    # Coordinates for each texture in the atlas will be retrievable by the index number.
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
    def initialize(@size : UInt32)
    end

    # Returns the coordinates for an index in the atlas.
    #
    # ## Example
    #
    # Given a 4x4 grid like this one:
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
    # texture_atlas.get_coordinates(9) # => { col: 1, row: 2}
    # ```
    def get_coords(index : UInt32) : TextureCoords
      position = Prism::TextureAtlas.get_position(index, @size)
      get_coords(position[:col], position[:row])
    end

    # Returns the coordinates for index at the given *col* and *row* in the atlas.
    def get_coords(col : UInt32, row : UInt32) : TextureCoords
      Prism::TextureAtlas.get_coords(col, row, @size)
    end

    protected def self.get_coords(col : UInt32, row : UInt32, size : UInt32) : TextureCoords
      # x offset
      left = (col / size).to_f32
      right = ((col + 1) / size).to_f32
      # y offset
      top = (row / size).to_f32
      bottom = ((row + 1) / size).to_f32
      {
        bottom_left:  Vector2f.new(left, bottom),
        bottom_right: Vector2f.new(right, bottom),
        top_right:    Vector2f.new(right, top),
        top_left:     Vector2f.new(left, top),
      }
    end

    # Converts an *index* in the map into a set of coordinates.
    #
    # ## Example
    #
    # Given a 4x4 grid like this one:
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
    # texture_atlas.get_coordinates(9) # => { col: 1, row: 2}
    # ```
    #
    # If the index is out of range it will wrap. e.g. an index of 16 becomes 1.
    # NOTE: coordinates are zero indexed.
    protected def self.get_position(index : UInt32, size : UInt32) : NamedTuple(col: UInt32, row: UInt32)
      wrapped_index = index % (size * size)
      {
        col: wrapped_index % size,
        row: (wrapped_index / size).floor.to_u32,
      }
    end
  end
end
