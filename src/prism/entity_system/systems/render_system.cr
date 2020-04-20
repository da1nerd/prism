module Prism::EntitySystem::Systems
  class RenderSystem < EntitySystem::System
    def initialize(@shader : Core::Shader::StaticShader)
    end

    def update(time : Float64)
    end
  end
end
