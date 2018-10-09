require "./game_component"
require "../rendering/mesh"
require "../rendering/material"
require "../rendering/shader"
require "../core/transform"

module Prism

  class MeshRenderer < GameComponent

    def initialize(@mesh : Mesh, @material : Material)
    end

    def render(shader : Shader, rendering_engine : RenderingEngineProtocol)
      shader.bind
      shader.update_uniforms(self.transform, @material, rendering_engine)
      @mesh.draw
    end

    def input(transform : Transform, delta : Float32)
    end

    def update(transform : Transform, delta : Float32)
    end
  end

end
