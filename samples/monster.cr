require "../src/prism"
require "./obstacle.cr"

include Prism

enum MonsterState
    Idle
    Chase
    Attack
    Dying
    Dead
end

class Monster < GameComponent
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
    HEIGHT = 0.2f32
    SIZE = Vector3f.new(WIDTH, HEIGHT, 0.1)

    MOVE_SPEED = 1.5f32
    MOVEMENT_STOP_DISTANCE = 0.5f32

    SHOOT_DISTANCE = 1000f32
    SHOT_ANGLE = 10f32
    ATTACK_CHANCE = 1.8f32
    MAX_HEALTH = 100

    @@mesh : Mesh?
    @material : Material
    @state : MonsterState
    @rendering_engine : RenderingEngineProtocol?
    @rand : Random
    @can_look : Bool
    @can_attack : Bool
    @monster_clock : Float32
    @health : Int32

    # TODO: receive material as parameter
    def initialize(@detector : CollisionDetector, @level : LevelMap)
        @state = MonsterState::Idle
        @monster_clock = 0
        @can_look = false
        @can_attack = false
        @health = MAX_HEALTH
        @material = Material.new
        @material.add_texture("diffuse", Texture.new("SSWVA1.png"))
        @material.add_float("specularIntensity", 1)
        @material.add_float("specularPower", 8)
        @rand = Random.new

        if @@mesh == nil
            # create new mesh

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
    end

    def position
        self.transform.pos
    end

    def size
        SIZE.rotate(self.transform.get_transformed_rot)
    end

    # Adds damage to the monster
    def damage(amount : Int32)
        if @state == MonsterState::Idle
            @state = MonsterState::Chase
        end

        @health -= amount
        puts @health

        if @health <= 0
            @state = MonsterState::Dying
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

            collision_vector = @level.check_intersections(line_start, line_end)

            player_intersect_vector = @level.line_intersect_rect(line_start, line_end, rendering_engine.main_camera.transform.get_transformed_pos.xz, Vector2f.new(Player::PLAYER_SIZE, Player::PLAYER_SIZE))

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
        if rendering_engine = @rendering_engine
            if self.can_react
                @can_look = true
            elsif @can_look
                line_start : Vector2f = transform.pos.xz
                cast_direction : Vector2f = (orientation.xz * -1f32)#.rotate((@rand.next_float.to_f32 - 0.5) * SHOT_ANGLE)
                line_end : Vector2f = line_start + cast_direction * SHOOT_DISTANCE

                collision_vector = @level.check_intersections(line_start, line_end)

                player_intersect_vector = @level.line_intersect_rect(line_start, line_end, rendering_engine.main_camera.transform.get_transformed_pos.xz, Vector2f.new(Player::PLAYER_SIZE, Player::PLAYER_SIZE))

                if pv = player_intersect_vector
                    if cv = collision_vector
                        if (player_intersect_vector - line_start).length < (collision_vector - line_start).length
                            puts "We've seen the player"
                            @state = MonsterState::Chase
                        else
                            # puts "We hit something"
                        end
                    else
                        puts "We've seen the player"
                        @state = MonsterState::Chase
                    end
                elsif cv = collision_vector
                    # puts "We hit something"
                end
                
                @can_look = false
            end
        end
    end

    private def chase_update(delta : Float32, orientation : Vector3f, distance : Float32)
        # TRICKY: multiply attack chance by delta to make it frame independent.
        if @rand.next_float < ATTACK_CHANCE * delta
            @state = MonsterState::Attack
        end

        if distance > MOVEMENT_STOP_DISTANCE
            move_amount = -MOVE_SPEED * delta
            old_pos = transform.pos
            new_pos = self.transform.pos + orientation * move_amount
            
            collision_vector = @detector.check_collision(old_pos, new_pos, Monster::WIDTH, Monster::HEIGHT)
            
            movement_vector = collision_vector * orientation
            if movement_vector.length > 0
                self.transform.pos = old_pos + movement_vector * move_amount
            end

            if (movement_vector - orientation).length != 0
                @level.open_doors(transform.pos)
            end
        else
            @state = MonsterState::Attack
        end
    end

    private def attack_update(delta : Float32, orientation : Vector3f, distance : Float32)
        if rendering_engine = @rendering_engine

            if self.can_react
                @can_attack = true
            elsif @can_attack
                line_start : Vector2f = transform.pos.xz
                cast_direction : Vector2f = (orientation.xz * -1f32).rotate((@rand.next_float.to_f32 - 0.5) * SHOT_ANGLE)
                line_end : Vector2f = line_start + cast_direction * SHOOT_DISTANCE
    
                collision_vector = @level.check_intersections(line_start, line_end)
    
                player_intersect_vector = @level.line_intersect_rect(line_start, line_end, rendering_engine.main_camera.transform.get_transformed_pos.xz, Vector2f.new(Player::PLAYER_SIZE, Player::PLAYER_SIZE))
    
                if pv = player_intersect_vector
                    if cv = collision_vector
                        if (player_intersect_vector - line_start).length < (collision_vector - line_start).length
                            puts "We've just shot the player"
                        else
                            puts "We hit something"
                        end
                    else
                        puts "We've just shot the player"
                    end
                elsif cv = collision_vector
                    puts "We hit something"
                end

                @can_attack = false
            end

            @state = MonsterState::Chase
        end
    end

    private def dying_update(delta : Float32)
        @state = MonsterState::Dead
    end

    private def dead_update(delta : Float32)
        puts "We're dead"
    end

    def update(delta : Float32)
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
        @rendering_engine = rendering_engine
        if mesh = @@mesh
            shader.bind
            shader.update_uniforms(self.transform, @material, rendering_engine)
            mesh.draw
        else
            puts "Error: The monster mesh has not been created"
            exit 1
        end
    end
end