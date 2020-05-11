module Prism
  # A generic shader for `Entity` objects.
  class EntityShader < Prism::DefaultShader
    MAX_LIGHTS = 1
    uniform "diffuse", Prism::Texture
    uniform "useFakeLighting", Bool
    uniform "reflectivity", Float32
    uniform "shineDamper", Float32
    uniform transformation_matrix, Matrix4f
    uniform projection_matrix, Matrix4f
    uniform view_matrix, Matrix4f
    # uniform light, Prism::Light
    uniform lights, StaticArray(Prism::Light, MAX_LIGHTS)
    # uniform eye_pos, Vector3f
    uniform sky_color, Vector3f
    uniform "numberOfRows", Float32
    uniform offset, Vector2f

    def initialize
      super("entity")
    end
  end
end
