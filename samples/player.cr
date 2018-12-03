require "../src/prism"
require "./position_mask.cr"
require "./position_lock.cr"
require "./collide_move.cr"
require "./collision_detector.cr"
require "./character.cr"
require "./gun.cr"

enum PlayerState
    Idle
    Walk
    Attack
    Hurt
end

# Represents a player in the game
class Player < Character

    GUN_OFFSET = -0.0775f32

    MOUSE_SENSITIVITY = 0.1375f32
    MOVEMENT_SPEED = 4f32
    DEFAULT_HEIGHT = 0.4375f32
    PLAYER_SIZE = 0.2f32
    SHOOT_DISTANCE = 1000f32
    DAMAGE_MIN = 20
    DAMAGE_MAX = 60
    MAX_HEALTH = 100

    @level : LevelMap?
    @rand : Random
    @window_height : Int32 = 1
    @window_width : Int32 = 1
    @player_clock : Float32
    @state : PlayerState
    @gun : Gun

    def initialize(position : Vector2f, detector : CollisionDetector, height : Float32 = DEFAULT_HEIGHT)
        super(Vector3f.new(position.x, height, position.y), MAX_HEALTH)
        @state = PlayerState::Idle
        @player_clock = 0
        @rand = Random.new
        @look = FreeLook.new(MOUSE_SENSITIVITY)
        @move = CollideMove.new(MOVEMENT_SPEED, detector)
        # TODO: make better way to get window dimensions
        aspect = @window_width.to_f32 / @window_height.to_f32
        @cam = Camera.new(Prism.to_rad(65.0f32), aspect, 0.01f32, 1000.0f32)
        @position_mask = PositionMask.new(Vector3f.new(1f32, 0f32, 1f32))
        @position_lock = PositionLock.new(Vector3f.new(0, height, 0))

        @gun = Gun.new
        @gun.transform.pos = Vector3f.new(0, GUN_OFFSET, 0.1)

        self.add_object(@gun)
        self.add_component(@look)
        self.add_component(@cam)
        self.add_component(@move)
        self.add_component(@position_mask)
        self.add_component(@position_lock)
    end

    def damage!(by : Int32)
        super
        puts health
        if dead?
            puts "You just died! GAME OVER!"
        end
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
        if input.get_key_pressed(Input::Key::E)
            self.get_level.open_doors(self.transform.pos, true)
        end

        size = input.window_size
        if @window_height != size[:height] || @window_width != size[:width]
            @window_height, @window_width = size[:height], size[:width]
            @cam.aspect = @window_width.to_f32 / @window_height.to_f32
        end

        if @look.mouse_locked
            if input.get_mouse_pressed(Input::MouseButton::Left)
                @gun.fire
                line_start = self.transform.pos.xz
                cast_direction = transform.rot.forward.xz.normalized
                line_end = line_start + (cast_direction * SHOOT_DISTANCE)
                self.get_level.check_intersections(line_start, line_end, true)
            end
        end
    end
end