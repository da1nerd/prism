require "annotations"

module Prism
  # A basic shape class that holds a mesh and a material.
  # Normally you'll want to inherit this class to create new shapes.
  class Shape < Entity
    @material : Material
    @mesh : Mesh?

    setter material

    def initialize
      super
      @material = Material.new
    end

    def initialize(mesh : Mesh)
      initialize(mesh, Material.new)
    end

    def initialize(@mesh : Mesh, @material : Material)
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
  end
end
