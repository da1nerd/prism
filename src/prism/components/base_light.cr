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

    # Binds an object's *transform* and *material* to the light shader.
    # This should be done just before drawing the object's `Prism::Mesh`
    def bind(transform : Transform, material : Material)
      if shader = self.shader
        shader.bind_new(to_uniform, transform, material, @engine.as(RenderingEngine))
      end
    end

    def add_to_engine(@engine : RenderingEngine)
      super
      @engine.as(RenderingEngine).add_light(self)
    end
  end
end
