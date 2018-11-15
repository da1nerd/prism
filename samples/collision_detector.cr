# Provides utilties for calculating collision
class CollisionDetector

    def initialize(@obstacles : Array(Obstacle))
    end

    # Checks if a collision occured and stops movement along the appropriate axis.
    def check_collision(old_pos : Vector3f, new_pos : Vector3f, object_width : Float32, object_length : Float32) : Vector3f
        collision_vector = Vector2f.new(1, 1)
        movement_vector = new_pos - old_pos

        if movement_vector.length > 0
            object_size = Vector2f.new(object_width, object_length)

            0.upto(@obstacles.size - 1) do |i|
                obstacle = @obstacles[i]
                collision_vector = collision_vector * rect_collide(old_pos.xz, new_pos.xz, object_size, obstacle.position.xz, obstacle.size.xz)
            end
        end

        return Vector3f.new(collision_vector.x, 0, collision_vector.y)
    end

    # Checks if two objects collide
    private def rect_collide(old_pos : Vector2f, new_pos : Vector2f, player_size : Vector2f, obj_pos : Vector2f, obj_size : Vector2f) : Vector2f
        result = Vector2f.new(0, 0)

        # x axis
        # players right edge < objects left edge || players left edge > object's right edge
        x_can_move = new_pos.x + player_size.x < obj_pos.x || new_pos.x - player_size.x > obj_pos.x + obj_size.x * obj_size.x
        y_can_move = old_pos.y + player_size.y < obj_pos.y || old_pos.y - player_size.y > obj_pos.y + obj_size.y * obj_size.y
        if x_can_move || y_can_move
            result.x = 1f32
        end

        distance_to_right_edge = obj_pos.x - (old_pos.x + player_size.x)
        distance_to_left_edge = (old_pos.x - player_size.x) - (obj_pos.x + obj_size.x * obj_size.x)

        # y axis
        x_can_move = old_pos.x + player_size.x < obj_pos.x || old_pos.x - player_size.x > obj_pos.x + obj_size.x * obj_size.x
        y_can_move = new_pos.y + player_size.y < obj_pos.y || new_pos.y - player_size.y > obj_pos.y + obj_size.y * obj_size.y
        if x_can_move || y_can_move
            result.y = 1f32
        end

        return result
    end
end