require "./game_component"
require "../rendering/shader"

module Prism
  # Represents an ambient light source.
  class AmbientLight < GameComponent
    @shader : Shader
    getter color, shader

    def initialize
      initialize(Vector3f.new(0.1, 0.1, 0.1))
    end

    def initialize(@color : Vector3f)
      @shader = Shader.new("forward-ambient")
    end

    def add_to_engine(engine : CoreEngine)
      engine.rendering_engine.ambient_light = self
    end
  end
end
