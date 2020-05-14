module Prism
  # A generic shader for the GUI
  class SkyboxShader < Prism::DefaultShader
    uniform "cubeMap", Prism::TextureCubeMap
    uniform "projectionMatrix", Matrix4f

    # Binds the view matrix to the shader.
    # TRICKY: this disables the translation so that the view is always centered acround the camera.
    def view_matrix=(matrix : Matrix4f)
      m = matrix.m
      m.[]=(0, 3, 0f32)
      m.[]=(1, 3, 0f32)
      m.[]=(2, 3, 0f32)
      set_uniform("viewMatrix", Matrix4f.new(m))
    end

    def initialize
      super("skybox")
    end
  end
end
