require "../src/prism"
require "./obstacle.cr"
require "./character.cr"
require "./monster_look.cr"

include Prism

enum MonsterState
    Idle
    Chase
    Attack
    Dying
    Dead
end

class Monster < Character
    include Obstacle

    SCALE = 0.55f32
    SIZE_Y = SCALE
    SIZE_X = SIZE_Y / (1.95 * 2)
    START = 0f32

    # offsets trim spacing around the texture
    OFFSET_X = 0.0f32
    OFFSET_Y = 0.0f32

    TEX_MAX_X = -OFFSET_X
    TEX_MIN_X = -(1 - OFFSET_X)
    TEX_MAX_Y = 1 - OFFSET_Y
    TEX_MIN_Y = - OFFSET_Y

    WIDTH = 0.2f32
    HEIGHT = SCALE
    LENGTH = 0.2f32
    SIZE = Vector3f.new(WIDTH, HEIGHT, LENGTH)

    MOVE_SPEED = 1.5f32
    MOVEMENT_STOP_DISTANCE = 0.5f32

    SHOOT_DISTANCE = 1000f32
    SHOT_ANGLE = 10f32
    ATTACK_CHANCE = 1.8f32
    MAX_HEALTH = 100
    DAMAGE_MIN = 5
    DAMAGE_MAX = 30

    @@mesh : Mesh?
    @@animations = [] of Texture
    @material : Material
    @state : MonsterState
    @rendering_engine : RenderingEngineProtocol?
    @rand : Random
    @can_look : Bool
    @can_attack : Bool
    @monster_clock : Float32
    # @health : Int32
    @level : LevelMap?
    @death_time : Float32 = 0

    # TODO: receive material as parameter
    def initialize(@detector : CollisionDetector)
        @material = Material.new
        super(Vector3f.new(0, 0, 0), MAX_HEALTH)
        
        if @@animations.size == 0
            @@animations = [] of Texture

            # walking
            @@animations.push(Texture.new("SSWVA1.png"))
            @@animations.push(Texture.new("SSWVB1.png"))
            @@animations.push(Texture.new("SSWVC1.png"))
            @@animations.push(Texture.new("SSWVD1.png"))

            # firing
            @@animations.push(Texture.new("SSWVE0.png"))
            @@animations.push(Texture.new("SSWVF0.png"))
            @@animations.push(Texture.new("SSWVG0.png"))

            # pain
            @@animations.push(Texture.new("SSWVH0.png"))

            # dying
            @@animations.push(Texture.new("SSWVI0.png"))
            @@animations.push(Texture.new("SSWVJ0.png"))
            @@animations.push(Texture.new("SSWVK0.png"))
            @@animations.push(Texture.new("SSWVL0.png"))

            # death
            @@animations.push(Texture.new("SSWVM0.png"))
        end

        # Build the monster mesh
        if @@mesh == nil
            verticies = [
                Vertex.new(Vector3f.new(SIZE_X, START, START), Vector2f.new(TEX_MIN_X, TEX_MAX_Y)),
                Vertex.new(Vector3f.new(SIZE_X, SIZE_Y, START), Vector2f.new(TEX_MIN_X, TEX_MIN_Y)),
                Vertex.new(Vector3f.new(-SIZE_X, SIZE_Y, START), Vector2f.new(TEX_MAX_X, TEX_MIN_Y)),
                Vertex.new(Vector3f.new(-SIZE_X, START, START), Vector2f.new(TEX_MAX_X, TEX_MAX_Y))
            ]
            indicies = [
                0, 1, 2,
                0, 2, 3
            ]
            @@mesh = Mesh.new(verticies, indicies, true)
        end
        
        @state = MonsterState::Idle
        @monster_clock = 0
        @can_look = false
        @can_attack = false
        @rand = Random.new
        
        @material.add_texture("diffuse", @@animations[0])
        @material.add_float("specularIntensity", 1)
        @material.add_float("specularPower", 8)

        self.add_component(MonsterLook.new)
        if mesh = @@mesh
            self.add_component(MeshRenderer.new(mesh, @material))
        end
    end

    def set_level(@level : LevelMap)
    end

    # Returns the damage given by the monster's gun
    def get_damage
        return @rand.rand(DAMAGE_MAX - DAMAGE_MIN) + DAMAGE_MIN
    end

    private def get_level
        if level = @level
            return level
        else
            puts "The level was not set on the monster"
            exit 1
        end
    end

    def position
        self.transform.get_transformed_pos
    end

    def size
        SIZE.rotate(self.transform.get_transformed_rot)
    end

    # Adds damage to the monster
    def damage!(by : Int32)
        super(by)

        if dead?
            @state = MonsterState::Dying
        elsif @state == MonsterState::Idle
            @state = MonsterState::Chase
        end
    end

    # Checks if the monster can react to things.
    # This is based on the monster clock so it does not think too often and slow down the game.
    private def can_react
        time = @monster_clock - @monster_clock.to_i32
        return time < 0.5
    end

    # Checks if the monster can see the player
    private def can_see_player
        if rendering_engine = @rendering_engine
            line_start : Vector2f = transform.pos.xz
            cast_direction : Vector2f = (orientation.xz * -1f32).rotate((@rand.next_float.to_f32 - 0.5) * SHOT_ANGLE)
            line_end : Vector2f = line_start + cast_direction * SHOOT_DISTANCE

            collision_vector = self.get_level.check_intersections(line_start, line_end)

            player_intersect_vector = self.get_level.line_intersect_rect(line_start, line_end, rendering_engine.main_camera.transform.get_transformed_pos.xz, Vector2f.new(Player::PLAYER_SIZE, Player::PLAYER_SIZE))

            if pv = player_intersect_vector
                if cv = collision_vector
                    if (player_intersect_vector - line_start).length < (collision_vector - line_start).length
                        return true
                    end
                else
                    return true
                end
            end
        end
        return false
    end

    private def idle_update(delta : Float32, orientation : Vector3f, distance : Float32)
        time_decimals : Float32 = @monster_clock - @monster_clock.to_i32
        if rendering_engine = @rendering_engine
            if time_decimals < 0.5
                @can_look = true
                @material.add_texture("diffuse", @@animations[0])
            else
                @material.add_texture("diffuse", @@animations[1])
                if @can_look
                    line_start : Vector2f = transform.pos.xz
                    cast_direction : Vector2f = (orientation.xz * -1f32)#.rotate((@rand.next_float.to_f32 - 0.5) * SHOT_ANGLE)
                    line_end : Vector2f = line_start + cast_direction * SHOOT_DISTANCE

                    collision_vector = self.get_level.check_intersections(line_start, line_end, false)

                    player_intersect_vector = self.get_level.line_intersect_rect(line_start, line_end, rendering_engine.main_camera.transform.get_transformed_pos.xz, Vector2f.new(Player::PLAYER_SIZE, Player::PLAYER_SIZE))

                    if pv = player_intersect_vector
                        if cv = collision_vector
                            if (player_intersect_vector - line_start).length < (collision_vector - line_start).length
                                # puts "We've seen the player"
                                @state = MonsterState::Chase
                            end
                        else
                            # puts "We've seen the player"
                            @state = MonsterState::Chase
                        end
                    end
                    
                    @can_look = false
                end
            end
        end
    end

    private def chase_update(delta : Float32, orientation : Vector3f, distance : Float32)
        time_decimals : Float32 = @monster_clock - @monster_clock.to_i32
        if time_decimals < 0.25
            @material.add_texture("diffuse", @@animations[0])
        elsif time_decimals < 0.5
            @material.add_texture("diffuse", @@animations[1])
        elsif time_decimals < 0.75
            @material.add_texture("diffuse", @@animations[2])
        else
            @material.add_texture("diffuse", @@animations[3])
        end
        
        # TRICKY: multiply attack chance by delta to make it frame independent.
        if @rand.next_float < ATTACK_CHANCE * delta
            @state = MonsterState::Attack
        end

        if distance > MOVEMENT_STOP_DISTANCE
            move_amount = -MOVE_SPEED * delta
            old_pos = transform.pos
            new_pos = self.transform.pos + orientation * move_amount
            
            collision_vector = @detector.check_collision(old_pos, new_pos, Monster::WIDTH, Monster::LENGTH)
            
            movement_vector = collision_vector * orientation
            if movement_vector.length > 0
                self.transform.pos = old_pos + movement_vector * move_amount
            end

            if (movement_vector - orientation).length != 0
                self.get_level.open_doors(transform.pos)
            end
        else
            @state = MonsterState::Attack
        end
    end

    private def attack_update(delta : Float32, orientation : Vector3f, distance : Float32)
        if rendering_engine = @rendering_engine

            time_decimals : Float32 = @monster_clock - @monster_clock.to_i32

            if time_decimals < 0.25
                @material.add_texture("diffuse", @@animations[4])
            elsif time_decimals < 0.5
                @material.add_texture("diffuse", @@animations[5])
            elsif time_decimals < 0.75
                @material.add_texture("diffuse", @@animations[6])
                if @can_attack
                    line_start : Vector2f = transform.pos.xz
                    cast_direction : Vector2f = (orientation.xz * -1f32).rotate((@rand.next_float.to_f32 - 0.5) * SHOT_ANGLE)
                    line_end : Vector2f = line_start + cast_direction * SHOOT_DISTANCE
        
                    collision_vector = self.get_level.check_intersections(line_start, line_end, false)
        
                    player_intersect_vector = self.get_level.line_intersect_rect(line_start, line_end, rendering_engine.main_camera.transform.get_transformed_pos.xz, Vector2f.new(Player::PLAYER_SIZE, Player::PLAYER_SIZE))
        
                    if pv = player_intersect_vector
                        if cv = collision_vector
                            if (player_intersect_vector - line_start).length < (collision_vector - line_start).length
                                # puts "We've just shot the player"
                                self.get_level.damage_player(self.get_damage)
                            end
                        else
                            # puts "We've just shot the player"
                            self.get_level.damage_player(self.get_damage)
                        end
                    end
                    @can_attack = false
                end
            elsif @can_attack == false
                @material.add_texture("diffuse", @@animations[5])
                @state = MonsterState::Chase
                @can_attack = true
            end
        end
    end

    private def dying_update(delta : Float32)
        time_decimals : Float32 = @monster_clock - @monster_clock.to_i32

        if @death_time == 0
            @death_time = @monster_clock
        end

        time1 = 0.1f32
        time2 = 0.3f32
        time3 = 0.45f32
        time4 = 0.6f32
    
        if @monster_clock < @death_time + time1
            @material.add_texture("diffuse", @@animations[8])
            transform.scale = Vector3f.new(1, 0.96428571, 1)
        elsif @monster_clock < @death_time + time2
            @material.add_texture("diffuse", @@animations[9])
            transform.scale = Vector3f.new(1.7, 0.9, 1)
        elsif @monster_clock < @death_time + time3
            @material.add_texture("diffuse", @@animations[10])
            transform.scale = Vector3f.new(1.7, 0.9, 1)
        elsif @monster_clock < @death_time + time4
            @material.add_texture("diffuse", @@animations[11])
            transform.scale = Vector3f.new(1.7, 0.5, 1)
        else
            @state = MonsterState::Dead
        end
    end

    private def dead_update(delta : Float32)
        @material.add_texture("diffuse", @@animations[12])
        transform.scale = Vector3f.new(1.75862068965517, 0.285714285714, 1)
    end

    def update(delta : Float32)
        super
        @monster_clock += delta
        if rendering_engine = @rendering_engine
            camera_pos = rendering_engine.main_camera.transform.get_transformed_pos;
            camera_pos.y = 0f32
            direction_to_camera = transform.pos - camera_pos
            distance = direction_to_camera.length
            orientation = direction_to_camera / distance

            case @state
            when MonsterState::Idle
                idle_update(delta, orientation, distance)
            when MonsterState::Chase
                chase_update(delta, orientation, distance)
            when MonsterState::Attack
                attack_update(delta, orientation, distance)
            when MonsterState::Dying
                dying_update(delta)
            when MonsterState::Dead
                dead_update(delta)
            end
        end
    end

    def render(shader : Shader, rendering_engine : RenderingEngineProtocol)
        super
        @rendering_engine = rendering_engine
    end
end