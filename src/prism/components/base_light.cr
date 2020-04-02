require "./game_component"
require "../core/vector3f"
require "../rendering/shader"

module Prism
  # Fundamental light component
  class BaseLight < GameComponent
    getter color, intensity, shader
    setter color, intensity, shader

    @shader : Shader?

    def initialize(@color : Vector3f, @intensity : Float32)
    end

    def add_to_engine(engine : RenderingEngine)
      engine.add_light(self)
    end
  end
end
