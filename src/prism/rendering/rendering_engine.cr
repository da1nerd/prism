require "lib_gl"
require "../components/camera"
require "../components/base_light"

module Prism

  class RenderingEngine

    @main_camera : Camera?
    @ambient_light : Vector3f

    getter ambient_light, active_light
    setter main_camera, active_light

    @lights : Array(BaseLight)
    @active_light : BaseLight?

    def initialize(window : CrystGLUT::Window)
      @lights = [] of BaseLight

      LibGL.clear_color(0.0f32, 0.0f32, 0.0f32, 0.0f32)

      LibGL.front_face(LibGL::CW)
      LibGL.cull_face(LibGL::BACK)
      LibGL.enable(LibGL::CULL_FACE)
      LibGL.enable(LibGL::DEPTH_TEST)

      LibGL.enable(LibGL::DEPTH_CLAMP)

      LibGL.enable(LibGL::TEXTURE_2D)

      @ambient_light = Vector3f.new(0.1f32, 0.1f32, 0.1f32)
    end

    def render(object : GameObject)
      clear_screen
      @lights.clear
      object.add_to_rendering_engine(self)

      forward_ambient = ForwardAmbient.instance
      forward_ambient.rendering_engine = self

      object.render(forward_ambient)

      LibGL.enable(LibGL::BLEND)
      LibGL.blend_func(LibGL::ONE, LibGL::ONE)
      LibGL.depth_mask(LibGL::FALSE)
      LibGL.depth_func(LibGL::EQUAL)

      0.upto(@lights.size - 1) do |i|
        light = @lights[i]
        if shader = light.shader
          shader.rendering_engine = self

          @active_light = light

          object.render(shader)
        end
      end

      LibGL.depth_func(LibGL::LESS)
      LibGL.depth_mask(LibGL::TRUE)
      LibGL.disable(LibGL::BLEND)
    end

    def add_light(light : BaseLight)
      @lights.push(light)
    end

    def add_camera(camera : Camera)
      @main_camera = camera
    end

    def main_camera : Camera
      if camera = @main_camera
        return camera
      else
        puts "Error: No camera has been set."
        exit 1
      end
    end

    private def clear_screen
      # TODO: stencil buffer
      LibGL.clear(LibGL::COLOR_BUFFER_BIT | LibGL::DEPTH_BUFFER_BIT)
    end

    # Enable/disables textures
    private def set_textures(enabled : Boolean)
      if enabled
        LibGL.enable(LibGL::TEXTURE_2D)
      else
        LibGL.disable(LibGL::TEXTURE_2D)
      end
    end

    def flush
      LibGL.flush()
    end

    # Returns which version of OpenGL is available
    def get_open_gl_version
      return String.new(LibGL.get_string(LibGL::VERSION))
    end

    private def set_clear_color(color : Vector3f)
      LibGL.clear_color(color.x, color.y, color.z, 1.0);
    end

    private def unbind_textures
      LibGL.bind_texture(LibGL::TEXTURE_2D, 0)
    end

  end

end
