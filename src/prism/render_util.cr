require "lib_gl"

module Prism

  class RenderUtil

    def self.clear_screen
      # TODO: stencil buffer
      LibGL.clear(LibGL::COLOR_BUFFER_BIT | LibGL::DEPTH_BUFFER_BIT)
    end

    def self.init_graphics
      LibGL.clear_color(0.0f32, 0.0f32, 0.0f32, 0.0f32)

      LibGL.front_face(LibGL::CW)
      LibGL.cull_face(LibGL::BACK)
      # TODO: enable culling for 3d objects. For now this culls the 2d sample in game.cr
      # LibGL.enable(LibGL::CULL_FACE)
      LibGL.enable(LibGL::DEPTH_TEST)

      # TODO: Depth clamp for later

      LibGL.enable(LibGL::FRAMEBUFFER_SRGB)
    end

    def self.flush
      LibGL.flush()
    end

    # Returns which version of OpenGL is available
    def self.get_open_gl_version
      return String.new(LibGL.get_string(LibGL::VERSION))
    end

  end

end
