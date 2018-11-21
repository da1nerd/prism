require "../src/prism"
require "./position_mask.cr"
require "./position_lock.cr"
require "./collide_move.cr"
require "./collision_detector.cr"
require "./character.cr"
require "./gun.cr"

# Represents a player in the game
class Player < Character

    # gun stuff
    # SCALE = 0.55f32
    # SIZE_Y = SCALE
    # SIZE_X = SIZE_Y / (1.0379747 * 2)
    # START = 0f32

    # offsets trim spacing around the texture
    # OFFSET_X = 0.0f32
    # OFFSET_Y = 0.0f32

    # TEX_MAX_X = -OFFSET_X
    # TEX_MIN_X = -(1 - OFFSET_X)
    # TEX_MAX_Y = 1 - OFFSET_Y
    # TEX_MIN_Y = - OFFSET_Y
    # end gun stuff

    MOUSE_SENSITIVITY = 0.4375f32
    MOVEMENT_SPEED = 6f32
    DEFAULT_HEIGHT = 0.4375f32
    PLAYER_SIZE = 0.2f32
    SHOOT_DISTANCE = 1000f32
    DAMAGE_MIN = 20
    DAMAGE_MAX = 60
    MAX_HEALTH = 100

    @level : LevelMap?
    @rand : Random
    # @gun_mesh : Mesh
    # @gun_material : Material

    def initialize(position : Vector2f, detector : CollisionDetector, height : Float32 = DEFAULT_HEIGHT)
        super(Vector3f.new(position.x, height, position.y), MAX_HEALTH)

        # create gun
        # verticies = [
        #     Vertex.new(Vector3f.new(SIZE_X, START, START), Vector2f.new(TEX_MIN_X, TEX_MAX_Y)),
        #     Vertex.new(Vector3f.new(SIZE_X, SIZE_Y, START), Vector2f.new(TEX_MIN_X, TEX_MIN_Y)),
        #     Vertex.new(Vector3f.new(-SIZE_X, SIZE_Y, START), Vector2f.new(TEX_MAX_X, TEX_MIN_Y)),
        #     Vertex.new(Vector3f.new(-SIZE_X, START, START), Vector2f.new(TEX_MAX_X, TEX_MAX_Y))
        # ]
        # indicies = [
        #     0, 1, 2,
        #     0, 2, 3
        # ]
        # @gun_mesh = Mesh.new(verticies, indicies, true)
        # @gun_material = Material.new()
        # @gun_material.add_texture("diffuse", Texture.new("PISGB0.png"))
        # @gun_material.add_float("specularIntensity", 1)
        # @gun_material.add_float("specularPower", 8)

        @rand = Random.new
        @look = FreeLook.new(MOUSE_SENSITIVITY)
        @move = CollideMove.new(MOVEMENT_SPEED, detector)
        # TODO: make better way to get window dimensions
        @cam = Camera.new(Prism.to_rad(70.0f32), 800f32/600f32, 0.01f32, 1000.0f32)
        @position_mask = PositionMask.new(Vector3f.new(1f32, 0f32, 1f32))
        @position_lock = PositionLock.new(Vector3f.new(0, height, 0))

        @gun = Gun.new
        # @gun.transform.pos
        # gun_obj = GameObject.new.add_component(@gun)
        @gun.transform.pos = Vector3f.new(0, 0, 0.1)
        # @gun.transform.look_at(self.transform.pos, @cam.transform.rot.up)
        # @gun.transform.rotate(@cam.transform.rot.up, 180)
        self.add_object(@gun)

        # self.add_component(MeshRenderer.new(@gun_mesh, @gun_material))
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
        if input.get_key_down(Input::KEY_E)
            self.get_level.open_doors(self.transform.pos)
        end

        if @look.mouse_locked
            if input.get_mouse_down(0)
                line_start = self.transform.pos.xz
                cast_direction = transform.rot.forward.xz.normalized
                line_end = line_start + (cast_direction * SHOOT_DISTANCE)
                self.get_level.check_intersections(line_start, line_end, true)
            end
        end
    end
end