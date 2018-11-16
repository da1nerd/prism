require "../src/prism"
require "./tween.cr"
require "./obstacle.cr"

include Prism

class Door < GameComponent
    include Obstacle

    # NOTE: add top and bottom face if you need hight less than 1
    START = 0f32
    LENGTH = 1f32
    WIDTH = 0.125f32
    HEIGHT = 1f32
    TIME_TO_OPEN = 0.5f32
    CLOSE_DELAY = 2.0f32
    SIZE = Vector3f.new(LENGTH, HEIGHT, WIDTH)

    @@mesh : Mesh?

    @material : Material
    @is_opening : Bool
    @close_position : Vector3f?
    @open_position: Vector3f?
    @open_movement : Vector3f
    @tween : Tween?

    def initialize(@material, @open_movement)
        @is_opening = false

        if @@mesh == nil
            # create new mesh

            verticies = [
                Vertex.new(Vector3f.new(START, START, START), Vector2f.new(0.5, 1)),
                Vertex.new(Vector3f.new(START, HEIGHT, START), Vector2f.new(0.5, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, HEIGHT, START), Vector2f.new(0.75, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, START, START), Vector2f.new(0.75, 1)),

                Vertex.new(Vector3f.new(START, START, START), Vector2f.new(0.73, 1)),
                Vertex.new(Vector3f.new(START, HEIGHT, START), Vector2f.new(0.73, 0.75)),
                Vertex.new(Vector3f.new(START, HEIGHT, WIDTH), Vector2f.new(0.75, 0.75)),
                Vertex.new(Vector3f.new(START, START, WIDTH), Vector2f.new(0.75, 1)),

                Vertex.new(Vector3f.new(START, START, WIDTH), Vector2f.new(0.5, 1)),
                Vertex.new(Vector3f.new(START, HEIGHT, WIDTH), Vector2f.new(0.5, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, HEIGHT, WIDTH), Vector2f.new(0.75, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, START, WIDTH), Vector2f.new(0.75, 1)),

                Vertex.new(Vector3f.new(LENGTH, START, START), Vector2f.new(0.73, 1)),
                Vertex.new(Vector3f.new(LENGTH, HEIGHT, START), Vector2f.new(0.73, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, HEIGHT, WIDTH), Vector2f.new(0.75, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, START, WIDTH), Vector2f.new(0.75, 1))
            ]
            indicies = [
                0, 1, 2,
                0, 2, 3,

                6, 5, 4,
                7, 6, 4,

                10, 9, 8,
                11, 10, 8,

                12, 13, 14,
                12, 14, 15
            ]
            @@mesh = Mesh.new(verticies, indicies, true)
        end
    end

    def position
        # TODO: the position is wrong on rotated doors
        self.transform.pos
    end

    def size
        # TODO: cache this
        SIZE.rotate(self.transform.rot)
    end

    # Returns or generates the door tween
    private def get_tween(delta : Float32, key_frame_time : Float32) : Tween
        if tween = @tween
            return tween
        else
            tween = Tween.new(delta, key_frame_time)
            @tween = tween
            return tween
        end
    end

    # Resets the tween progress to the beginning
    private def reset_tween
        if tween = @tween
            tween.reset
        end
    end

    private def get_open_position : Vector3f
        if position = @open_position
            return position
        else
            position = self.transform.pos - @open_movement
            @open_position = position
            return position
        end
    end

    private def get_close_position : Vector3f
        if position = @close_position
            return position
        else
            position = self.transform.pos
            @close_position = position
            return position
        end
    end

    # Opens the door
    # Toggles the door being opened and closed
    def open
        return if @is_opening || @is_closing
        reset_tween
        # TODO: auto close the door
        @is_opening = self.transform.pos == self.get_close_position
        @is_closing = self.transform.pos == self.get_open_position
    end

    def input(delta : Float32, input : Input)
    end

    def update(delta : Float32)
        close_position = self.get_close_position
        open_position = self.get_open_position

        if @is_opening || @is_closing
            tween = get_tween(delta, TIME_TO_OPEN)
            lerp_factor = tween.step
            self.transform.pos = self.transform.pos.lerp(@is_opening ? open_position : close_position, lerp_factor)
            if lerp_factor == 1
                @is_opening = false
                @is_closing = false
            end
        end
    end

    def render(shader : Shader, rendering_engine : RenderingEngineProtocol)
        if mesh = @@mesh
            shader.bind
            shader.update_uniforms(self.transform, @material, rendering_engine)
            mesh.draw
        else
            puts "Error: The door mesh has not been created"
            exit 1
        end
    end

end