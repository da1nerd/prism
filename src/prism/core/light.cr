require "./shader"
require "./game_component"

module Prism::Core
  # Fundamental light component
  abstract class Light < GameComponent
    include Shader::Serializable
    # property shader

    @shader : Shader::ShaderEngine

    def initialize(@shader : Shader::ShaderEngine)
    end

    # Binds an object's *transform* and *material* to the light shader.
    # This should be done just before drawing the object's `Prism::Mesh`
    def on(transform : Transform, material : Material, camera : Camera)
      @shader.start(self.to_uniform, transform, material, camera)
    end

    # Turns off the light
    def off
      @shader.stop
    end

    def add_to_engine(engine : Core::RenderingEngine)
      engine.add_light(self)
    end
  end
end
