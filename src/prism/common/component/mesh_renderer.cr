module Prism::Common::Component
  # Renders a mesh (shape) with some material (texture) applied to it.
  class MeshRenderer < Core::Component
    def initialize(@mesh : Core::Mesh, @material : Core::Material)
    end

    @[Override]
    def render(&block : Core::RenderCallback)
      block.call self.transform, @material, @mesh
    end
  end
end
