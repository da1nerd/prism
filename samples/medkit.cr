require "../src/prism"
require "./watch_camera.cr"

class MedKit < GameObject

    PICKUP_DISTANCE = 0.5f32
    HEAL_AMOUNT = 25

    SCALE = 0.525f32
    SIZE_Y = SCALE
    SIZE_X = SIZE_Y / (1.0379747 * 2)
    START = 0f32

    # offsets trim spacing around the texture
    OFFSET_X = 0.0f32
    OFFSET_Y = 0.0f32

    TEX_MIN_X = -OFFSET_X
    TEX_MAX_X = -1 - OFFSET_X
    TEX_MIN_Y = - OFFSET_Y
    TEX_MAX_Y = 1 - OFFSET_Y

    @@mesh : Mesh?
    @@material : Material?

    @rendering_engine : RenderingEngineProtocol?

    def initialize(position : Vector2f, @level : LevelMap)
        super()

        self.transform.pos = Vector3f.new(position.x, 0, position.y)

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

        if @@material == nil
            material = Material.new()
            material.add_texture("diffuse", Texture.new("MEDIA0.png"))
            material.add_float("specularIntensity", 1)
            material.add_float("specularPower", 8)
            @@material = material
        end
        if mesh = @@mesh
            if material = @@material
                self.add_component(MeshRenderer.new(mesh, material))
            end
        end

        self.add_component(WatchCamera.new)
    end

    def get_level
        if level = @level
            level
        else
            puts "You did not assign the level to the medkit"
            exit 1
        end
    end

    def render(shader : Shader, @rendering_engine : RenderingEngineProtocol)
        super
    end

    def update(delta : Float32)
        super

        if rendering_engine = @rendering_engine
            camera_pos = rendering_engine.main_camera.transform.get_transformed_pos;
            camera_pos.y = 0f32
            direction_to_camera = transform.pos - camera_pos

            if direction_to_camera.length < PICKUP_DISTANCE
                @level.get_player.heal!(HEAL_AMOUNT)
                puts "+#{HEAL_AMOUNT} health!"

                @level.remove_medkit(self)
            end
        end
    end
end