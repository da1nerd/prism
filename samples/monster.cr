require "../src/prism"

include Prism

class Monster < GameComponent

    SCALE = 0.7f32
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

    @@mesh : Mesh?
    @material : Material

    # TODO: receive material as parameter
    def initialize()
        @material = Material.new
        @material.add_texture("diffuse", Texture.new("SSWVA1.png"))
        @material.add_float("specularIntensity", 1)
        @material.add_float("specularPower", 8)

        if @@mesh == nil
            # create new mesh

            verticies = [
                Vertex.new(Vector3f.new(-SIZE_X, START, START), Vector2f.new(TEX_MAX_X, TEX_MAX_Y)),
                Vertex.new(Vector3f.new(-SIZE_X, SIZE_Y, START), Vector2f.new(TEX_MAX_X, TEX_MIN_Y)),
                Vertex.new(Vector3f.new(SIZE_X, SIZE_Y, START), Vector2f.new(TEX_MIN_X, TEX_MIN_Y)),
                Vertex.new(Vector3f.new(SIZE_X, START, START), Vector2f.new(TEX_MIN_X, TEX_MAX_Y))
            ]
            indicies = [
                0, 1, 2,
                0, 2, 3
            ]
            @@mesh = Mesh.new(verticies, indicies, true)
        end
    end

    def update(delta : Float32)

    end

    def render(shader : Shader, rendering_engine : RenderingEngineProtocol)
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