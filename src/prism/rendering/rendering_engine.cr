require "lib_gl"
require "../components/camera"
require "../components/base_light"
require "./rendering_engine_protocol"
require "./resource_management/mapped_values"

module Prism
  class RenderingEngine < MappedValues
    include RenderingEngineProtocol

    @sampler_map : Hash(String, LibGL::Int)
    @lights : Array(BaseLight)
    @active_light : BaseLight?
    @forward_ambient : Shader
    @main_camera : Camera?

    getter active_light
    setter main_camera, active_light

    def initialize(window : CrystGLUT::Window)
      super()

      @lights = [] of BaseLight
      @sampler_map = {} of String => LibGL::Int
      @sampler_map["diffuse"] = 0

      add_vector("ambient", Vector3f.new(0.2f32, 0.2f32, 0.2f32))

      @forward_ambient = Shader.new("forward-ambient")

      LibGL.clear_color(0.0f32, 0.0f32, 0.0f32, 0.0f32)

      LibGL.front_face(LibGL::CW)
      LibGL.cull_face(LibGL::BACK)
      LibGL.enable(LibGL::CULL_FACE)
      LibGL.enable(LibGL::DEPTH_TEST)

      LibGL.enable(LibGL::DEPTH_CLAMP)

      LibGL.enable(LibGL::TEXTURE_2D)
    end

    def render(object : GameObject)
      LibGL.clear(LibGL::COLOR_BUFFER_BIT | LibGL::DEPTH_BUFFER_BIT)

      @lights.clear
      object.add_to_rendering_engine(self)

      object.render(@forward_ambient, self)

      LibGL.enable(LibGL::BLEND)
      LibGL.blend_func(LibGL::ONE, LibGL::ONE)
      LibGL.depth_mask(LibGL::FALSE)
      LibGL.depth_func(LibGL::EQUAL)

      0.upto(@lights.size - 1) do |i|
        light = @lights[i]
        if shader = light.shader
          @active_light = light

          object.render(shader, self)
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

    def flush
      LibGL.flush
    end

    # Returns which version of OpenGL is available
    def get_open_gl_version
      return String.new(LibGL.get_string(LibGL::VERSION))
    end

    def get_sampler_slot(sampler_name : String) : LibGL::Int
      @sampler_map[sampler_name]
    end
  end
end
