require "../src/prism"

include Prism

class Door < GameComponent
    # NOTE: add top and bottom face if you need hight less than 1
    LENGTH = 1f32
    WIDTH = 0.125f32
    HEIGHT = 1f32

    @@mesh : Mesh?
    @material : Material

    def initialize(@material)
        if @@mesh == nil
            # create new mesh

            verticies = [
                Vertex.new(Vector3f.new(0, 0, 0), Vector2f.new(0.5, 1)),
                Vertex.new(Vector3f.new(0, HEIGHT, 0), Vector2f.new(0.5, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, HEIGHT, 0), Vector2f.new(0.75, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, 0, 0), Vector2f.new(0.75, 1)),

                Vertex.new(Vector3f.new(0, 0, 0), Vector2f.new(0.73, 1)),
                Vertex.new(Vector3f.new(0, HEIGHT, 0), Vector2f.new(0.73, 0.75)),
                Vertex.new(Vector3f.new(0, HEIGHT, WIDTH), Vector2f.new(0.75, 0.75)),
                Vertex.new(Vector3f.new(0, 0, WIDTH), Vector2f.new(0.75, 1)),

                Vertex.new(Vector3f.new(0, 0, WIDTH), Vector2f.new(0.5, 1)),
                Vertex.new(Vector3f.new(0, HEIGHT, WIDTH), Vector2f.new(0.5, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, HEIGHT, WIDTH), Vector2f.new(0.75, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, 0, WIDTH), Vector2f.new(0.75, 1)),

                Vertex.new(Vector3f.new(LENGTH, 0, 0), Vector2f.new(0.73, 1)),
                Vertex.new(Vector3f.new(LENGTH, HEIGHT, 0), Vector2f.new(0.73, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, HEIGHT, WIDTH), Vector2f.new(0.75, 0.75)),
                Vertex.new(Vector3f.new(LENGTH, 0, WIDTH), Vector2f.new(0.75, 1))
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

    # Returns the door as an obstacle
    def as_obstacle : Obstacle
        Obstacle.new(self.transform.pos, Vector3f.new(LENGTH, HEIGHT, WIDTH))
    end

    def input(delta : Float32, input : Input)
    end

    def update(delta : Float32)
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