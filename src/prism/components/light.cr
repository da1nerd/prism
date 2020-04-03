require "./game_component"
require "../core/vector3f"
require "../rendering/shader"

module Prism
  # Fundamental light component
  class Light < GameComponent
    include Uniform::Serializable
    property shader

    @shader : Shader?
    @engine : RenderingEngine?

    # Binds an object's *transform* and *material* to the light shader.
    # This should be done just before drawing the object's `Prism::Mesh`
    def bind(transform : Transform, material : Material)
      if shader = @shader
        # TODO: passing in the rendering engine is deprecated
        shader.bind_new(to_uniform, transform, material, @engine.as(RenderingEngine))
      end
    end

    def add_to_engine(@engine : RenderingEngine)
    end
  end
end
