require "../src/prism"
require "./collision_detector.cr"

# Custom movement component that provides hacky collision detection.
class CollideMove < GameComponent

    def initialize(speed : Float32, detector : CollisionDetector)
        initialize(speed, detector, Input::Key::W, Input::Key::S, Input::Key::A, Input::Key::D)
    end

    def initialize(@speed : Float32, @detector : CollisionDetector, @forward_key : Input::Key, @back_key : Input::Key, @left_key : Input::Key, @right_key : Input::Key)
        @movement = Vector3f.new(0, 0, 0)
    end

    def input(delta : Float32, input : Input)
        @movement = Vector3f.new(0, 0, 0)

        if input.get_key(@forward_key)
        @movement += self.transform.rot.forward
        end
        if input.get_key(@back_key)
        @movement += self.transform.rot.back
        end
        if input.get_key(@left_key)
        @movement += self.transform.rot.left
        end
        if input.get_key(@right_key)
        @movement += self.transform.rot.right
        end
    end

    def update(delta : Float32)
        if @movement.length > 0
            @movement = @movement.normalized
            mov_amt = @speed * delta

            old_pos = self.transform.pos
            new_pos = old_pos + @movement * mov_amt

            collision_vector = @detector.check_collision(old_pos, new_pos, Player::PLAYER_SIZE, Player::PLAYER_SIZE)
            @movement *= collision_vector
            move(@movement, mov_amt)
        end
    end

    # moves the camera
    def move(direction : Vector3f, amount : Float32)
        self.transform.pos = self.transform.pos + direction * amount
    end
end