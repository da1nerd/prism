module Prism

    # Simplifies generating square sprite texture coordinates
    # by mapping the actual coordinates to a grid system.
    class Spritemap

        # Creates a new map of *width* sprites by *height* sprites.
        def initialize(@width : UInt8, @height : UInt8)
        end

        # Returns the corners of the sprite.
        #
        # Each corner is labeled accordingly: top_left, top_right, bottom_right, bottom_left
        def get(x : UInt8, y : UInt8) : NamedTuple(bottom_left: Vector2f, bottom_right: Vector2f, top_right: Vector2f, top_left: Vector2f)
            left = (x.to_f32) / @width.to_f32
            right = (x.to_f32 + 1) / @width.to_f32
            top = (y.to_f32) / @height.to_f32
            bottom = (y.to_f32 + 1) / @height.to_f32
            {
                bottom_left: Vector2f.new(left, bottom),
                bottom_right: Vector2f.new(right, bottom),
                top_right: Vector2f.new(right, top),
                top_left: Vector2f.new(left, top)
            }
        end
    end
end