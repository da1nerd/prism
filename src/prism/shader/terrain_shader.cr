module Prism::Shader
  # TODO: move this into stdlib
  class TerrainShader < Program
    uniform :texture, Prism::TexturePack
    uniform "specularIntensity", Float32
    uniform "specularPower", Float32
    uniform transformation_matrix, Matrix4f
    uniform projection_matrix, Matrix4f
    uniform view_matrix, Matrix4f
    uniform light, Prism::Light
    uniform eye_pos, Vector3f
    uniform sky_color, Vector3f

    def initialize
      super("terrain")
    end
  end
end
