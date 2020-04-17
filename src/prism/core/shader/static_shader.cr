module Prism::Core::Shader
  class StaticShader < Program
    @@programs = {} of String => CompiledProgram

    inline_uniform material, Material

    def initialize
      super("static")
    end
  end
end
