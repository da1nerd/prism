require "annotation"
require "./rendering/shader"
require "./game_component.cr"

module Prism
  # Fundamental light component
  class Light < GameComponent
    include Shader::Serializable
    # property shader

    @shader : Shader

    def initialize(@shader : Shader)
    end

    # Binds an object's *transform* and *material* to the light shader.
    # This should be done just before drawing the object's `Prism::Mesh`
    def bind(transform : Transform, material : Material, camera : Camera)
      @shader.bind(self.to_uniform, transform, material, camera)
    end

    def add_to_engine(engine : RenderingEngine)
      engine.add_light(self)
    end
  end
end
