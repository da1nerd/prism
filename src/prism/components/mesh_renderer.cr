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

    def render(shader : Shader, rendering_engine : RenderingEngine)
      shader.bind
      shader.update_uniforms(self.transform, @material, rendering_engine)
      @mesh.draw
    end
  end
end
