require "./vector3f"

module Prism
    # Represents a color value in the engine.
    struct Colors
        @color: Vector3f

        def initialize(@red, @green, @blue)
            @color = Vector3f.new(@red, @green, @blue)
        end
        
        def self.white
            Color.new(1, 1, 1)
        end

        # Returns the color vector
        def as_vector3f
            @color
        end
    end
end