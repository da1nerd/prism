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
      # TODO: enable culling for 3d objects
      # LibGL.enable(LibGL::CULL_FACE)
      LibGL.enable(LibGL::DEPTH_TEST)

      # TODO: Depth clamp for later

      LibGL.enable(LibGL::FRAMEBUFFER_SRGB)
    end

    def self.flush
      LibGL.flush()
    end

  end

end