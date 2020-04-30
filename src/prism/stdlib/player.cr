module Prism
    class Player < Crash::Component
        include Prism::Adapter::GLFW

        RUN_SPEED = 20f32
        TURN_SPEED = 160f32
        Y_AXIS = Vector3f.new(0, 1, 0)
        GRAVITY = -50.0f32
        JUMP_POWER = 30f32
        TERRAIN_HEIGHT = 0f32

        @current_speed : Float32 = 0
        @current_turn_speed : Float32 = 0
        @upwards_speed : Float32 = 0
        @is_in_air : Bool = false

        def input!(tick : RenderLoop::Tick, input : RenderLoop::Input, transform : Prism::Transform)
            # move
            if input.get_key(Window::Key::W)
                @current_speed = RUN_SPEED
            elsif input.get_key(Window::Key::S)
                @current_speed = -RUN_SPEED
            else
                @current_speed = 0
            end

            # turn
            if input.get_key(Window::Key::D)
                @current_turn_speed = TURN_SPEED
            elsif input.get_key(Window::Key::A)
                @current_turn_speed = -TURN_SPEED
            else
                @current_turn_speed = 0
            end

            # jump
            if input.get_key(Window::Key::Space) && !@is_in_air
                @upwards_speed = JUMP_POWER
                @is_in_air = true
            end

            turn_amount = @current_turn_speed * tick.frame_time.to_f32
            move_amount = @current_speed * tick.frame_time.to_f32

            transform.rotate(Y_AXIS, Prism::Maths.to_rad(turn_amount))
            transform.pos = transform.pos + transform.rot.forward * move_amount

            # gravity slows jump speed
            @upwards_speed += GRAVITY * tick.frame_time.to_f32
            puts @upwards_speed
            transform.pos.y += @upwards_speed * tick.frame_time.to_f32
            if transform.pos.y < TERRAIN_HEIGHT
                @is_in_air = false
                @upwards_speed = 0
                transform.pos.y = TERRAIN_HEIGHT
            end
        end
    end
end