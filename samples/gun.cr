require "../src/prism"

class Gun < GameObject
    SCALE = 0.0625f32
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

    def initialize
        super
        # Build the gun mesh
        if @@mesh == nil
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

        if @@material == nil
            material = Material.new()
            material.add_texture("diffuse", Texture.new("PISGB0.png"))
            material.add_float("specularIntensity", 1)
            material.add_float("specularPower", 8)
            @@material = material
        end

        if mesh = @@mesh
            if material = @@material
                self.add_component(MeshRenderer.new(mesh, material))
            end
        end
    end

    # def render(shader : Shader, rendering_engine : RenderingEngineProtocol)
    #     puts "pos #{transform.pos.to_s}"
    #     # puts "rot #{transform.rot.to_s}"
    #     # puts "scl #{transform.scale.to_s}"
    #     if mesh = @@mesh
    #         if material = @@material
    #             shader.bind
    #             shader.update_uniforms(self.transform, material, rendering_engine)
    #             mesh.draw
    #         end
    #     end
    # end
end