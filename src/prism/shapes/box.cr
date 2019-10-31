require "./shape"

module Prism
    module Shapes
        class Box < Shape

            def initialize(@size : Float32)
                initialize(@size, {
                    bottom_left:  Vector2f.new(0, 0),
                    top_left:     Vector2f.new(0, 1),
                    bottom_right: Vector2f.new(1, 0),
                    top_right:    Vector2f.new(1, 1)
                })
            end

            def initialize(@size : Float32, @texture_coords : SpriteCoords)
                super()

                field_depth = 1.0f32
                field_width = 1.0f32

                verticies = [
                    # bottom
                    Vertex.new(Vector3f.new(0, 0, 0), @texture_coords[:bottom_left]),
                    Vertex.new(Vector3f.new(0, 0, @size), @texture_coords[:bottom_right]),
                    Vertex.new(Vector3f.new(@size, 0, @size), @texture_coords[:top_right]),
                    Vertex.new(Vector3f.new(@size, 0, 0), @texture_coords[:top_left]),

                    # top
                    Vertex.new(Vector3f.new(0, @size, 0), @texture_coords[:bottom_left]),
                    Vertex.new(Vector3f.new(0, @size, @size), @texture_coords[:bottom_right]),
                    Vertex.new(Vector3f.new(@size, @size, @size), @texture_coords[:top_right]),
                    Vertex.new(Vector3f.new(@size, @size, 0), @texture_coords[:top_left]),

                    # back
                    Vertex.new(Vector3f.new(0, 0, @size), @texture_coords[:bottom_left]),
                    Vertex.new(Vector3f.new(0, @size, @size), @texture_coords[:bottom_right]),
                    Vertex.new(Vector3f.new(@size, @size, @size), @texture_coords[:top_right]),
                    Vertex.new(Vector3f.new(@size, 0, @size), @texture_coords[:top_left]),

                    # front
                    Vertex.new(Vector3f.new(0, 0, 0), @texture_coords[:bottom_left]),
                    Vertex.new(Vector3f.new(0, @size, 0), @texture_coords[:bottom_right]),
                    Vertex.new(Vector3f.new(@size, @size, 0), @texture_coords[:top_right]),
                    Vertex.new(Vector3f.new(@size, 0, 0), @texture_coords[:top_left]),

                    # left
                    Vertex.new(Vector3f.new(0, 0, 0), @texture_coords[:bottom_left]),
                    Vertex.new(Vector3f.new(0, 0, @size), @texture_coords[:bottom_right]),
                    Vertex.new(Vector3f.new(0, @size, @size), @texture_coords[:top_right]),
                    Vertex.new(Vector3f.new(0, @size, 0), @texture_coords[:top_left]),

                    # right
                    Vertex.new(Vector3f.new(@size, 0, 0), @texture_coords[:bottom_left]),
                    Vertex.new(Vector3f.new(@size, 0, @size), @texture_coords[:bottom_right]),
                    Vertex.new(Vector3f.new(@size, @size, @size), @texture_coords[:top_right]),
                    Vertex.new(Vector3f.new(@size, @size, 0), @texture_coords[:top_left])
                ]

                indicies = Array(LibGL::Int) {
                    0, 3, 2,
                    0, 2, 1,

                    4, 5, 6,
                    4, 6, 7,

                    8, 11, 10,
                    8, 10, 9,

                    12, 13, 14,
                    12, 14, 15,

                    16, 17, 18,
                    16, 18, 19,

                    20, 23, 22,
                    20, 22, 21
                }
                
                @mesh = Mesh.new(verticies, indicies, true)
            end
        end

    end
end