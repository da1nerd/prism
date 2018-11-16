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

    MOVE_SPEED = 1f32
    MOVEMENT_STOP_DISTANCE = 0.5f32

    @@mesh : Mesh?
    @material : Material
    @state : MonsterState
    @rendering_engine : RenderingEngineProtocol?

    # TODO: receive material as parameter
    def initialize()
        @state = MonsterState::Chase
        @material = Material.new
        @material.add_texture("diffuse", Texture.new("SSWVA1.png"))
        @material.add_float("specularIntensity", 1)
        @material.add_float("specularPower", 8)

        if @@mesh == nil
            # create new mesh

            verticies = [
                Vertex.new(Vector3f.new(SIZE_X, START, START), Vector2f.new(TEX_MAX_X, TEX_MAX_Y)),
                Vertex.new(Vector3f.new(SIZE_X, SIZE_Y, START), Vector2f.new(TEX_MAX_X, TEX_MIN_Y)),
                Vertex.new(Vector3f.new(-SIZE_X, SIZE_Y, START), Vector2f.new(TEX_MIN_X, TEX_MIN_Y)),
                Vertex.new(Vector3f.new(-SIZE_X, START, START), Vector2f.new(TEX_MIN_X, TEX_MAX_Y))
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

    private def idle_update(delta : Float32)
        
    end

    private def chase_update(delta : Float32, orientation : Vector3f, distance : Float32)
        if distance > MOVEMENT_STOP_DISTANCE
            old_pos = transform.pos
            new_pos = self.transform.pos + orientation * -MOVE_SPEED * delta
            
            # collision_vector = 
            self.transform.pos = new_pos
        end
    end

    private def attack_update(delta : Float32)

    end

    private def dying_update(delta : Float32)

    end

    private def dead_update(delta : Float32)

    end

    def update(delta : Float32)
        if rendering_engine = @rendering_engine
            camera_pos = rendering_engine.main_camera.transform.get_transformed_pos;
            camera_pos.y = 0f32
            direction_to_camera = transform.pos - camera_pos
            distance = direction_to_camera.length
            orientation = direction_to_camera / distance

            case @state
            when MonsterState::Idle
                idle_update(delta)
            when MonsterState::Chase
                chase_update(delta, orientation, distance)
            when MonsterState::Attack
                attack_update(delta)
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