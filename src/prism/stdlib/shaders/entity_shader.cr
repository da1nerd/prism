module Prism
  # A generic shader for `Entity` objects.
  class EntityShader < Prism::DefaultShader
    # MAX_LIGHTS = 4

    uniform "diffuse", Prism::Texture
    uniform "useFakeLighting", Bool
    uniform "specularIntensity", Float32
    uniform "specularPower", Float32
    uniform transformation_matrix, Matrix4f
    uniform projection_matrix, Matrix4f
    uniform view_matrix, Matrix4f
    uniform light, Prism::Light
    uniform lights, Array(Prism::Light)
    uniform eye_pos, Vector3f
    uniform sky_color, Vector3f
    uniform "numberOfRows", Float32
    uniform offset, Vector2f

    def initialize
      super("entity")
    end
  end
end
