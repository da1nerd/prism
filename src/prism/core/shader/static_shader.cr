module Prism::Core::Shader
  class StaticShader < Program
    @@programs = {} of String => CompiledProgram

    inline_uniform material, Material
    uniform transformation_matrix, Matrix4f
    uniform projection_matrix, Matrix4f

    def initialize
      super("static")
    end
  end
end
