require "./game_component"
require "../core/vector3f"
require "../rendering/shader"

module Prism
  # Fundamental light component
  class BaseLight < Light
    include Uniform::Serializable

    @[Uniform::Field(key: "color")]
    @color : Vector3f

    @[Uniform::Field(key: "intensity")]
    @intensity : Float32

    property color, intensity

    @engine : RenderingEngine?

    def initialize(@color, @intensity : Float32)
    end

    def add_to_engine(@engine : RenderingEngine)
      super
      @engine.as(RenderingEngine).add_light(self)
    end
  end
end
