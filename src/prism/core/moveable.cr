module Prism
    module Moveable
        @transform : Transform

        # Elevates the object to the exact position
        def elevate_to(position : Float32)
            @transform.pos = @transform.rot.up * position
        end

        # Changes the object's elevation by the distance
        def elevate_by(amount : Float32)
            @transform.pos += @transform.rot.up * amount
        end

        # Rotates the shape around the x-axis
        def rotate_x_axis(angle)

        end

        # Rotates the shape around the y-axis
        def rotate_y_axis(angle)
        end

        # Moves the shape towards north by the *distance*
        def move_north(distance)
        end

        # Moves the shape towards east by the *distance*
        def move_east(distance)
        end
    end
end