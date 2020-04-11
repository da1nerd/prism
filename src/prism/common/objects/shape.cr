require "annotations"

module Prism::Common::Objects
  # A basic shape class that holds a mesh and a material.
  # Normally you'll want to inherit this class to create new shapes.
  class Shape < Core::GameObject
    @material : Core::Material?
    @mesh : Core::Mesh?

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

    @[Override]
    def render(&block : Core::RenderCallback)
      if mesh = @mesh
        if material = @material
          block.call self.transform, material, mesh
        end
      end
    end
  end
end
