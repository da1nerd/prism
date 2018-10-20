require "../src/prism"


class DetectCollision < GameComponent

    def initialize(@level : LevelMap, @player : Player)
    end

    def update(delta : Float32)
        # TODO: this is super hacky. we need a better way to handle collision detection
        old_pos = @player.transform.pos
        new_pos = old_pos + @player.movement

        collision_vector = @level.check_collision(old_pos, new_pos, Player::PLAYER_SIZE, Player::PLAYER_SIZE)
        @player.movement *= collision_vector
    end
end