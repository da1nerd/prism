module Prism
  # A generic shader for `Entity` objects.
  class EntityShader < Prism::DefaultShader
    # TRICKY: This must match the number of lights in your glsl code.
    MAX_LIGHTS = 4

    uniform "diffuse", Prism::Texture2D
    uniform "useFakeLighting", Bool
    uniform "reflectivity", Float32
    uniform "shineDamper", Float32
    uniform transformation_matrix, Matrix4f
    uniform projection_matrix, Matrix4f
    uniform view_matrix, Matrix4f
    uniform lights, StaticArray(Prism::PointLight, MAX_LIGHTS)
    uniform sky_color, Vector3f
    uniform "numberOfRows", Float32
    uniform offset, Vector2f

    def initialize
      super("entity")
    end
  end
end
