require "./game_component"
require "../core/vector3f"
require "../rendering/shader"

module Prism
  # Fundamental light component
  @[Uniform::Serializable::Options(struct: "BaseLight")] # TODO: this does not work
  class BaseLight < GameComponent
    include Uniform::Serializable

    @[Uniform::Field(struct: "BaseLight", key: "color")]
    @color : Vector3f

    @[Uniform::Field(struct: "BaseLight", key: "intensity")]
    @intensity : Float32

    property color, intensity, shader

    @shader : Shader?

    def initialize(@color, @intensity : Float32)
      to_uniform
    end

    def add_to_engine(engine : RenderingEngine)
      engine.add_light(self)
    end
  end
end
