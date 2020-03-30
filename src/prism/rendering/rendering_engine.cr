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
    @forward_ambient : Shader?
    @main_camera : Camera?

    getter active_light
    setter main_camera, active_light

    def initialize
      super()
      @lights = [] of BaseLight
      @sampler_map = {} of String => LibGL::Int
      @sampler_map["diffuse"] = 0

      LibGL.clear_color(0.0f32, 0.0f32, 0.0f32, 0.0f32)
      LibGL.front_face(LibGL::CW)
      LibGL.cull_face(LibGL::BACK)
      LibGL.enable(LibGL::CULL_FACE)
      LibGL.enable(LibGL::DEPTH_TEST)
      LibGL.enable(LibGL::DEPTH_CLAMP)
      LibGL.enable(LibGL::TEXTURE_2D)
    end

    # Give the programmer a chance to manually handle uniform structs in their GLSL code.
    # This allows for the edge case in which programmers want to define new structs in their shaders.
    # This method can be overridden to provide support for those custom structs.
    def update_uniform_struct(transform : Transform, material : Material, shader : Shader, uniform_name : String, uniform_type : String)
      puts "Error: #{uniform_type} is not a supported type in Rendering Engine"
      exit 1
    end

    def render(object : GameObject)
      puts "rendering object"
      LibGL.clear(LibGL::COLOR_BUFFER_BIT | LibGL::DEPTH_BUFFER_BIT)

      puts "rendering ambient_light"
      object.render_all(self.ambient_light, self)

      LibGL.enable(LibGL::BLEND)
      LibGL.blend_equation(LibGL::FUNC_ADD)
      LibGL.blend_func(LibGL::ONE, LibGL::ONE_MINUS_SRC_ALPHA)

      LibGL.depth_mask(LibGL::FALSE)
      LibGL.depth_func(LibGL::EQUAL)

      puts "rendering lights"
      @lights.each do |light|
        if shader = light.shader
          @active_light = light

          object.render_all(shader, self)
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

    # Returns the ambient light
    # If no light has been specified a default light is created
    def ambient_light : Shader
      if shader = @forward_ambient
        return shader
      else
        puts "Adding default ambient light..."
        add_vector("ambient", Vector3f.new(0.1f32, 0.1f32, 0.1f32))
        puts "creating new forward-ambient shader for ambient light"
        shader = Shader.new("forward-ambient")
        @forward_ambient = shader
        return shader
      end
    end

    # Changes the active ambient light
    def ambient_light=(ambient_light : AmbientLight)
      add_vector("ambient", ambient_light.color)
      @forward_ambient = ambient_light.shader
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
