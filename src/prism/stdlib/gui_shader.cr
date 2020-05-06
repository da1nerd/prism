module Prism
  class GUIShader < Prism::Shader::Program
    uniform "guiTexture", Prism::Texture
    uniform "transformationMatrix", Matrix4f

    def initialize
      super("gui")
    end
  end
end
