require "../src/prism"
require "./position_mask.cr"
require "./position_lock.cr"
require "./collide_move.cr"
require "./collision_detector.cr"

# Represents a player in the game
class Player < GameObject
    MOUSE_SENSITIVITY = 0.4375f32
    MOVEMENT_SPEED = 6f32
    DEFAULT_HEIGHT = 0.4375f32
    PLAYER_SIZE = 0.2f32
    SHOOT_DISTANCE = 1000f32
    DAMAGE_MIN = 20
    DAMAGE_MAX = 60

    @level : LevelMap?
    @rand : Random

    def initialize(position : Vector2f, detector : CollisionDetector, height : Float32 = DEFAULT_HEIGHT)
        super()
        @rand = Random.new
        @look = FreeLook.new(MOUSE_SENSITIVITY)
        @move = CollideMove.new(MOVEMENT_SPEED, detector)
        # TODO: make better way to get window dimensions
        @cam = Camera.new(Prism.to_rad(70.0f32), 800f32/600f32, 0.01f32, 1000.0f32)
        @position_mask = PositionMask.new(Vector3f.new(1f32, 0f32, 1f32))
        @position_lock = PositionLock.new(Vector3f.new(0, height, 0))

        self.add_component(@look)
        self.add_component(@cam)
        self.add_component(@move)

        self.add_component(@position_mask)
        self.add_component(@position_lock)

        self.transform.pos = Vector3f.new(position.x, height, position.y)
    end

    # Returns the damage given by the player gun
    def get_damage
        return @rand.rand(DAMAGE_MAX - DAMAGE_MIN) + DAMAGE_MIN
    end

    def set_level(@level : LevelMap)
    end

    private def get_level
        if level = @level
            return level
        else
            puts "The level was not set on the player"
            exit 1
        end
    end

    def input(delta : Float32, input : Input)
        super
        if input.get_key_down(Input::KEY_E)
            self.get_level.open_doors(self.transform.pos)
        end

        if @look.mouse_locked
            if input.get_mouse_down(0)
                line_start = self.transform.pos.xz
                cast_direction = transform.rot.forward.xz.normalized
                line_end = line_start + (cast_direction * SHOOT_DISTANCE)
                puts "pow!"
                self.get_level.check_intersections(line_start, line_end, true)
            end
        end
    end
end