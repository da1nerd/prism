require "../core/game_object"

module Prism
    module Shapes
        abstract class Shape < GameObject

            @material : Material?
            @mesh: Mesh?

            setter material

            # Reverses the face of the shape.
            # The face is the visible material of the shape
            def reverse_face
                if mesh = @mesh
                    mesh.reverse_face
                    @mesh = mesh
                end
            end

            def render(shader : Shader, rendering_engine : RenderingEngineProtocol)
                if mesh = @mesh
                    if material = @material
                        shader.bind
                        shader.update_uniforms(self.transform, material, rendering_engine)
                        mesh.draw
                    end
                end
            end
        end
    end
end