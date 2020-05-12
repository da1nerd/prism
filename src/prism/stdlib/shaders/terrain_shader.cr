module Prism
  # A generic shader for the terrain
  class TerrainShader < Prism::DefaultShader
    # TRICKY: This must match the number of lights in your glsl code.
    MAX_LIGHTS = 4

    uniform "backgroundTexture", Prism::Texture
    uniform "blendMap", Prism::Texture
    uniform "rTexture", Prism::Texture
    uniform "gTexture", Prism::Texture
    uniform "bTexture", Prism::Texture
    uniform "reflectivity", Float32
    uniform "shineDamper", Float32
    uniform transformation_matrix, Matrix4f
    uniform projection_matrix, Matrix4f
    uniform view_matrix, Matrix4f
    uniform lights, StaticArray(Prism::Light, MAX_LIGHTS)
    uniform sky_color, Vector3f

    def initialize
      super("terrain")
    end
  end
end
