require "../src/prism"

enum GunState
    Idle
    Fire
end

class Gun < GameObject
    SCALE = 0.0625f32
    SIZE_Y = SCALE
    SIZE_X = 102f32 * SIZE_Y / (85f32 * 2) # TRICKY: these are the texture dimensions
    START = 0f32

    # offsets trim spacing around the texture
    OFFSET_X = 0.0f32
    OFFSET_Y = 0.0f32

    TEX_MIN_X = -OFFSET_X
    TEX_MAX_X = -1 - OFFSET_X
    TEX_MIN_Y = - OFFSET_Y
    TEX_MAX_Y = 1 - OFFSET_Y

    @@mesh : Mesh?
    @material : Material
    @@animations = [] of Texture
    @clock : Float32
    @state : GunState
    @fire_start : Float32

    def initialize
        super
        @fire_start = 0
        @material = Material.new
        @clock = 0
        @state = GunState::Idle

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

        if @@animations.size == 0
            # idle
            @@animations.push(Texture.new("PISGB0.png"))
            # fire
            @@animations.push(Texture.new("PISFA0.png"))
        end

        @material.add_texture("diffuse", @@animations[0])
        @material.add_float("specularIntensity", 1)
        @material.add_float("specularPower", 8)

        if mesh = @@mesh
            self.add_component(MeshRenderer.new(mesh, @material))
        end
    end

    # Starts a fire animation
    # TODO: the fire method could take a block that will do the actual firing.
    # This way the gun can control when/if the fire logic is executed.
    def fire
        @fire_start = 0;
        @state = GunState::Fire
    end

    def idle_update(delta : Float32)
        @material.add_texture("diffuse", @@animations[0])
    end

    def fire_update(delta : Float32)
        if @fire_start == 0
            @fire_start = @clock
        end

        fire_period : Float32 = @clock - @fire_start

        if fire_period < 0.1
            @material.add_texture("diffuse", @@animations[1])
        else
            @state = GunState::Idle
        end
    end

    def update(delta : Float32)
        super
        @clock += delta
        case @state
        when GunState::Idle
            idle_update(delta)
        when GunState::Fire
            fire_update(delta)
        end
    end
end