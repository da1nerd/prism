require "lib_gl"
require "annotation"
require "../components/camera"
require "../components/base_light"
require "./uniform"

module Prism
  # Expose the graphics language integer values so keep a clean abstraction.
  alias GraphicsInt = LibGL::Int

  # Manages the OpenGL environment and renders game objects
  class RenderingEngine < Prism::Core::Engine
    include Uniform

    @window_size : Core::Size?
    @sampler_map : Hash(String, LibGL::Int)
    @lights : Array(Light)
    @ambient_light : Light?
    @main_camera : Camera?

    setter main_camera

    def initialize
      super()
      @lights = [] of Light
      @sampler_map = {} of String => LibGL::Int
      @sampler_map["diffuse"] = 0 # TODO: what is this?
    end

    # Prepares the GL environment as the rendering loop is starting up
    @[Override]
    def startup
      LibGL.clear_color(0.0f32, 0.0f32, 0.0f32, 0.0f32)
      LibGL.front_face(LibGL::CW)
      # Uncomment these lines to enable culling the back face for better performance.
      # LibGL.cull_face(LibGL::BACK)
      # LibGL.enable(LibGL::CULL_FACE)
      LibGL.enable(LibGL::DEPTH_TEST)
      LibGL.enable(LibGL::DEPTH_CLAMP)
      LibGL.enable(LibGL::TEXTURE_2D)
    end

    # Keep track of the window size at each tick so we can keep the viewport in sync
    @[Override]
    def tick(tick : Prism::Core::Tick, input : Prism::Core::Input)
      @window_size = input.window_size
    end

    # Flush the GL buffers and resize the viewport to match the window size
    @[Override]
    def flush
      if window_size = @window_size
        LibGL.viewport(0, 0, window_size[:width], window_size[:height])
      end

      LibGL.flush
    end

    def render(object : GameObject)
      LibGL.clear(LibGL::COLOR_BUFFER_BIT | LibGL::DEPTH_BUFFER_BIT)

      object.render_all(self.ambient_light.as(Light), self)

      LibGL.enable(LibGL::BLEND)
      LibGL.blend_equation(LibGL::FUNC_ADD)
      LibGL.blend_func(LibGL::ONE, LibGL::ONE_MINUS_SRC_ALPHA)

      LibGL.depth_mask(LibGL::FALSE)
      LibGL.depth_func(LibGL::EQUAL)

      @lights.each do |light|
        object.render_all(light, self)
      end

      LibGL.depth_func(LibGL::LESS)
      LibGL.depth_mask(LibGL::TRUE)
      LibGL.disable(LibGL::BLEND)
    end

    def add_light(light : Light)
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

    # Returns the ambient light
    # If no light has been specified a default light is created
    def ambient_light : Light
      if light = @ambient_light
        return light
      else
        ambient = AmbientLight.new
        ambient.add_to_engine self
        ambient
      end
    end

    # Changes the active ambient light
    def ambient_light=(@ambient_light : AmbientLight)
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
