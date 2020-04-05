require "./game_component"
require "../core/vector3f"
require "../rendering/shader"

module Prism
  # Fundamental light component
  class Light < GameComponent
    include Uniform::Serializable
    property shader

    @shader : Shader?

    # Binds an object's *transform* and *material* to the light shader.
    # This should be done just before drawing the object's `Prism::Mesh`
    def bind(transform : Transform, material : Material, camera : Camera)
      if shader = @shader
        shader.bind(to_uniform, transform, material, camera)
      end
    end
  end
end
