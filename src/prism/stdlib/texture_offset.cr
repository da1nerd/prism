module Prism
  # This indicates an offset to a texture.
  # The actual offset is determined by using a `TextureAtlas` specific to the texture that will be drawn on the object.
  #
  # The offset information is meant to be used in the shader to re-calculate the texture coordinates.
  #
  # ## Example
  #
  # ```
  # // inside your vertex shader file
  # vec2 updatedTextureCoords = (textureCoords / numRows) + offset;
  # ```
  #
  # If you want to re-calculate your texture coordinates before sending them to the shader
  # You should use the `TextureAtlas` directly.
  class TextureOffset < Crash::Component
    # Creates a new texture offset.
    # Internally this will create a `TextureAtlas` to calculate the offset coordinates.
    # *index* should be a value between `0` and `num_rows^2 - 1` inclusive.
    def initialize(num_rows : UInt32, index : UInt32)
      initialize(TextureAtlas.new(num_rows), index)
    end

    # Creates a new offset component using the *atlas*, and *index* into the atlas.
    # *index* should be a value between `0` and `atlas.size^2 - 1` inclusive.
    def initialize(@atlas : TextureAtlas, @index : UInt32)
    end

    # Returns the texture offset.
    def offset : Vector2f
      @atlas.get_coords(@index)[:top_right]
    end

    # Returns the number of rows in the atlas.
    def num_rows : Float32
      @atlas.size.to_f32
    end
  end
end
