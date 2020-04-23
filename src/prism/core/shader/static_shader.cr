module Prism::Core::Shader
  class StaticShader < Program
    inline_uniform material, Material
    uniform transformation_matrix, Matrix4f
    uniform projection_matrix, Matrix4f
    uniform view_matrix, Matrix4f
    uniform light, Core::Light
    uniform eye_pos, Vector3f

    def initialize
      super("static")
    end
  end
end
