require "../core/game_component"
require "../rendering/mesh"
require "../rendering/material"
require "../core/transform"

module Prism
  # Renders a mesh (shape) with some material (texture) applied to it
  class MeshRenderer < GameComponent
    def initialize(@mesh : Mesh, @material : Material)
    end

    def render(light : Light, rendering_engine : RenderingEngine)
      light.bind(self.transform, @material, rendering_engine.main_camera)
      @mesh.draw
    end
  end
end
