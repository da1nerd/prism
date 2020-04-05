require "./game_component"
require "../core/vector3f"
require "../rendering/shader"

module Prism
  # Fundamental light component
  class BaseLight < Light
    include Shader::Serializable

    @[Shader::Field(key: "color")]
    @color : Vector3f

    @[Shader::Field(key: "intensity")]
    @intensity : Float32

    property color, intensity

    # TODO: deprecate this
    @engine : RenderingEngine?

    def initialize(@color, @intensity : Float32)
    end

    def add_to_engine(@engine : RenderingEngine)
      @engine.as(RenderingEngine).add_light(self)
    end
  end
end
