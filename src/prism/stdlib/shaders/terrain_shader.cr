module Prism
  # A generic shader for the terrain
  class TerrainShader < Prism::DefaultShader
    # TRICKY: This must match the number of lights in your glsl code.
    MAX_LIGHTS = 4

    uniform "backgroundTexture", Prism::Texture2D
    uniform "blendMap", Prism::Texture2D
    uniform "rTexture", Prism::Texture2D
    uniform "gTexture", Prism::Texture2D
    uniform "bTexture", Prism::Texture2D
    uniform "reflectivity", Float32
    uniform "shineDamper", Float32
    uniform transformation_matrix, Matrix4f
    uniform projection_matrix, Matrix4f
    uniform view_matrix, Matrix4f
    uniform lights, StaticArray(Prism::PointLight, MAX_LIGHTS)
    uniform sky_color, Vector3f

    def initialize
      super("terrain")
    end
  end
end
