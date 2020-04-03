require "./game_component"
require "../rendering/mesh"
require "../rendering/material"
require "../rendering/shader"
require "../core/transform"

module Prism
  # Renders a mesh (shape) with some material (texture) applied to it
  class MeshRenderer < GameComponent
    def initialize(@mesh : Mesh, @material : Material)
    end

    def render(light : Light, rendering_engine : RenderingEngine)
      light.bind(self.transform, @material)
      @mesh.draw
    end
  end
end
