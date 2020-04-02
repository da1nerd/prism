require "./game_component"
require "../core/vector3f"
require "../rendering/shader"

module Prism

  # Fundamental light component
  @[Uniform::Serializable::Options(struct: "BaseLight")]
  class BaseLight < GameComponent
    include Uniform::Serializable

    @[Uniform::Field(key: "color")]
    @color : Vector3f

    @[Uniform::Field(key: "intensity")]
    @intensity : Float32

    property color, intensity, shader

    @shader : Shader?

    def initialize(@color, @intensity : Float32)
      self.to_uniform
      # TODO: this is UGLY! we could at least put this in a macro to hide it.
      # @shader.register_uniform_struct("BaseLight", [
      #   UniformProperty(Vector3f).new("color", @color),
      #   UniformProperty(Float32).new("intensity", @intensity),
      # ])
      # @shader.add_uniform("color", @color)
      # @shader.add_uniform("intensity", @intensity)
    end

    def add_to_engine(engine : RenderingEngine)
      engine.add_light(self)
    end
  end
end
