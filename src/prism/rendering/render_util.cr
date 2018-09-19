require "lib_gl"
require "../core/vector3f"

module Prism

  class RenderUtil

    def self.clear_screen
      # TODO: stencil buffer
      LibGL.clear(LibGL::COLOR_BUFFER_BIT | LibGL::DEPTH_BUFFER_BIT)
    end

    # Enable/disables textures
    def self.set_textures(enabled : Boolean)
      if enabled
        LibGL.enable(LibGL::TEXTURE_2D)
      else
        LibGL.disable(LibGL::TEXTURE_2D)
      end
    end

    def self.init_graphics
      LibGL.clear_color(0.0f32, 0.0f32, 0.0f32, 0.0f32)

      LibGL.front_face(LibGL::CW)
      LibGL.cull_face(LibGL::BACK)
      LibGL.enable(LibGL::CULL_FACE)
      LibGL.enable(LibGL::DEPTH_TEST)

      LibGL.enable(LibGL::DEPTH_CLAMP)

      LibGL.enable(LibGL::TEXTURE_2D)
    end

    def self.flush
      LibGL.flush()
    end

    # Returns which version of OpenGL is available
    def self.get_open_gl_version
      return String.new(LibGL.get_string(LibGL::VERSION))
    end

    def self.set_clear_color(color : Vector3f)
      LibGL.clear_color(color.x, color.y, color.z, 1.0);
    end

    def self.unbind_textures
      LibGL.bind_texture(LibGL::TEXTURE_2D, 0)
    end

  end

end
