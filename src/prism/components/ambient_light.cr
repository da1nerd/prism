require "./game_component"
require "../rendering/shader"
require "./light"

module Prism
  # Represents an ambient light source.
  class AmbientLight < Light
    include Shader::Serializable
    getter color

    @[Shader::Field(key: "R_ambient")]
    @color : Vector3f

    def initialize
      initialize(Vector3f.new(0.1, 0.1, 0.1))
    end

    def initialize(@color : Vector3f)
      self.shader = Shader.new("forward-ambient")
    end

    # TODO: deprecate this
    def add_to_engine(engine : RenderingEngine)
      engine.ambient_light = self
    end
  end
end
