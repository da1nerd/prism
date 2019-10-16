module Prism
    module Moveable
        @transform : Transform

        # Elevates the object to the exact position
        def elevate_to(position : Float32)
            # TODO: use parent transformation
            @transform.pos = @transform.rot.up * position
        end

        # Changes the object's elevation by the distance
        def elevate_by(amount : Float32)
            @transform.pos += @transform.rot.up * amount
            self
        end

        # Rotates the shape around the x-axis
        def rotate_x_axis(angle)
            @transform.rotate(Vector3f.new(1, 0, 0), angle)
            self
        end

        # Rotates the shape around the y-axis
        def rotate_y_axis(angle)
            @transform.rotate(Vector3f.new(0, 1, 0), angle)
            self
        end

        # Rotates the shape around the z-axis
        def rotate_z_axis(angle)
            @transform.rotate(Vector3f.new(0, 0, 1), angle)
            self
        end

        # Moves the shape towards north by the *distance*
        def move_north(distance : Float32)
            @transform.pos = @transform.get_transformed_pos +  Vector3f.new(0, 0, 1) * distance
            self
        end

        def move_south(distance : Float32)
            move_north(-distance)
            self
        end

        # Moves the shape towards east by the *distance*
        def move_east(distance : Float32)
            @transform.pos = @transform.get_transformed_pos +  Vector3f.new(1, 0, 0) * distance
            self
        end

        def move_west(distance : Float32)
            move_east(-distance)
            self
        end
    end
end