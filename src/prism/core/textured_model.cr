module Prism::Core
  # Represents a mesh (model) that has been textured.
  # Technically this is a model with a `Material` but MaterialedModel just sounds dumb.
  # There's some inconsistency with naming in the code. Meshes should just be called models, and all of the obj loading files in core/model needs to be organized.
  class TexturedModel
    getter mesh, texture

    def initialize(@mesh : Mesh, @material : Material)
    end
  end
end
