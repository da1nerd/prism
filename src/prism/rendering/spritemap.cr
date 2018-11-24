module Prism

    # Simplifies generating square sprite texture coordinates
    # by mapping the actual coordinates to a grid system.
    class Spritemap

        # Creates a new map of *width* sprites by *height* sprites.
        def initialize(@width : UInt8, @height : UInt8)
        end

        # Returns the four vertices for the sprite.
        # Verticies begin in the bottom left corner and proceed clockwise.
        def get(x : UInt8, y : UInt8) : StaticArray(Vector2f, 4)
            left = (x.to_f32) / @width.to_f32
            right = (x.to_f32 + 1) / @width.to_f32
            top = (y.to_f32) / @height.to_f32
            bottom = (y.to_f32 + 1) / @height.to_f32
            StaticArray[
                Vector2f.new(left, bottom),
                Vector2f.new(left, top),
                Vector2f.new(right, top),
                Vector2f.new(right, bottom)
            ]
        end

        # Same as `get` except returns the verticies in counter-clockwise order
        def get_cc(x : UInt8, y : UInt8) : StaticArray(Vector2f, 4)
            left = (x.to_f32) / @width.to_f32
            right = (x.to_f32 + 1) / @width.to_f32
            top = (y.to_f32) / @height.to_f32
            bottom = (y.to_f32 + 1) / @height.to_f32
            StaticArray[
                Vector2f.new(left, bottom),
                Vector2f.new(right, bottom),
                Vector2f.new(right, top),
                Vector2f.new(left, top)
            ]
        end
    end
end