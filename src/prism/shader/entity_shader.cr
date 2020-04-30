require "../shader/program"

module Prism::Shader
  class EntityShader < Prism::Shader::Program
    uniform :texture, Prism::TexturePack
    uniform "useFakeLighting", Bool
    uniform "specularIntensity", Float32
    uniform "specularPower", Float32
    uniform transformation_matrix, Matrix4f
    uniform projection_matrix, Matrix4f
    uniform view_matrix, Matrix4f
    uniform light, Prism::Light
    uniform eye_pos, Vector3f
    uniform sky_color, Vector3f

    def initialize
      super("entity")
    end
  end
end
