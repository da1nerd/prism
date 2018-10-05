require "lib_gl"
require "../rendering/camera"
require "../rendering/spot_light"
require "../components/directional_light"
require "../components/point_light"
require "../components/base_light"
require "./rendering_engine_protocol"

module Prism

  class RenderingEngine
    include RenderingEngineProtocol

    @main_camera : Camera
    @ambient_light : Vector3f

    getter main_camera, ambient_light, active_light
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

      @main_camera = Camera.new(to_rad(70.0), window.get_width.to_f32/window.get_height.to_f32, 0.01f32, 1000.0f32)
      @ambient_light = Vector3f.new(0.1, 0.1, 0.1)
    end

    def render(object : GameObject)
      clear_screen
      @lights.clear
      object.add_to_rendering_engine(self)

      forward_ambient = ForwardAmbient.instance
      forward_directional = ForwardDirectional.instance
      forward_point = ForwardPoint.instance
      forward_spot = ForwardSpot.instance
      forward_ambient.rendering_engine = self
      forward_directional.rendering_engine = self
      forward_point.rendering_engine = self
      forward_spot.rendering_engine = self

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

    # temporary hack
    def input(delta : Float32, input : Input)
      @main_camera.input(delta, input)
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
