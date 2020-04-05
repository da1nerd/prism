require "../core/game_object"

module Prism
  module Shapes
    class Shape < GameObject
      @material : Material?
      @mesh : Mesh?

      setter material

      def initialize
        super
      end

      def initialize(@mesh)
        super()
      end

      def initialize(@mesh, @material)
        super()
      end

      # Reverses the face of the shape.
      # The face is the visible material of the shape
      def reverse_face
        if mesh = @mesh
          mesh.reverse_face
          @mesh = mesh
        end
      end

      def render(light : Light, rendering_engine : RenderingEngine)
        if mesh = @mesh
          if material = @material
            light.bind(self.transform, material, rendering_engine.main_camera)
            mesh.draw
          end
        end
      end
    end
  end
end
