module Prism
    # TODO: make this a struct and pass this around instead of radian values
    module Angle
        extend self

        # Returns the radian value of the angle *degrees*
        #
        def from_degrees(degrees) : Float32
            degrees / 180f32 * Math::PI
        end
    end
end