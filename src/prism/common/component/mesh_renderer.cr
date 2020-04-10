module Prism::Common::Component
  # Renders a mesh (shape) with some material (texture) applied to it.
  class MeshRenderer < Core::GameComponent
    def initialize(@mesh : Core::Mesh, @material : Core::Material)
    end

    @[Override]
    def render(light : Core::Light, rendering_engine : Core::RenderingEngine)
      light.bind(self.transform, @material, rendering_engine.main_camera)
      @mesh.draw
    end
  end
end
