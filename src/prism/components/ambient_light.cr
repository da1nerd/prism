require "./game_component"
require "../rendering/shader"
require "./light"

module Prism
  # Represents an ambient light source.
  class AmbientLight < Light
    include Uniform::Serializable
    getter color

    @[Uniform::Field]
    @color : Vector3f

    def initialize
      initialize(Vector3f.new(0.1, 0.1, 0.1))
    end

    def initialize(@color : Vector3f)
      self.shader = Shader.new("forward-ambient")
    end

    def add_to_engine(engine : RenderingEngine)
      super
      engine.ambient_light = self
    end
  end
end
