module Prism
  # A generic shader for the GUI
  class SkyboxShader < Prism::DefaultShader
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

    # TODO: This is a temporary solution to binding cube maps.
    #  Eventually I want to automate this so we can use the uniform macro.
    #  This will probably require another type of texture.
    #  We could make `Texture` abstract, with an abstract bind method.
    #  Then we could create a Texture2D and a TextureCubeMap.
    def cube_map=(texture : Prism::Texture)
      slot = get_uniform_location("cubeMap")
      LibGL.active_texture(LibGL::TEXTURE0 + slot)
      LibGL.bind_texture(LibGL::TEXTURE_CUBE_MAP, texture.id)
      set_uniform("cubeMap", slot)
    end

    def initialize
      super("skybox")
    end
  end
end
