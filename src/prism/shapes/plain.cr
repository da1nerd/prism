require "./shape"
require "../core/vector3f"
require "../rendering/mesh"
require "lib_gl"

module Prism
    module Shapes
        class Plain < Shape
            def initialize(@width : Float32, @depth : Float32)
                super()
                # TODO: build mesh

                field_depth = 1.0f32
                field_width = 1.0f32

                @verticies = [
                    # Vertex.new(Vector3f.new(-field_width, 0, -field_depth), Vector2f.new(0, 0)),
                    # Vertex.new(Vector3f.new(-field_width, 0, field_depth * 3), Vector2f.new(0, 1)),
                    # Vertex.new(Vector3f.new(field_width * 3, 0, -field_depth), Vector2f.new(1, 0)),
                    # Vertex.new(Vector3f.new(field_width * 3, 0, field_depth * 3), Vector2f.new(1, 1))
                    Vertex.new(Vector3f.new(-field_width, 0, -field_depth), Vector2f.new(0, 0)),
                    Vertex.new(Vector3f.new(-field_width, 0, field_depth * @depth), Vector2f.new(0, 1)),
                    Vertex.new(Vector3f.new(field_width * @width, 0, -field_depth), Vector2f.new(1, 0)),
                    Vertex.new(Vector3f.new(field_width * @width, 0, field_depth * @depth), Vector2f.new(1, 1))
                ]

                @indicies = Array(LibGL::Int) {
                    0, 1, 2,
                    2, 1, 3
                }
                
                @mesh = Mesh.new(@verticies, @indicies, true)
            end

            # Reverses the face of the mesh
            def flip_face
                indicies = [] of LibGL::Int
                0.upto((@indicies.size // 3) - 1) do |i|
                    offset = i * 3
                    indicies << @indicies[offset + 2]
                    indicies << @indicies[offset + 1]
                    indicies << @indicies[offset]
                end
                @indicies = indicies
                @mesh = Mesh.new(@verticies, @indicies, true)
            end
        end
    end
end