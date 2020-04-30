module Prism::Shader
  class TerrainShader < Program
    # TODO: replace the material here with a texture pack
    inline_uniform material, Material
    # uniform :texture, Prism::TexturePack
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
