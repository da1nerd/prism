require "lib_gl"
require "annotation"

# require "../camera"

module Prism::Core
  # Expose the graphics language integer values so keep a clean abstraction.
  alias GraphicsInt = LibGL::Int
  alias RenderCallback = (Transform, Material, Mesh) -> Nil

  # Manages the OpenGL environment and renders game objects
  class RenderingEngine < RenderLoop::Engine
    @window_size : RenderLoop::Size?
    @lights : Array(Core::Light)
    @ambient_light : Core::Light?
    @main_camera : Core::Camera?
    @shader : Shader::StaticShader?
    @renderer : Renderer?

    setter main_camera

    def initialize
      super()
      @lights = [] of Core::Light
    end

    # Prepares the GL environment as the rendering loop is starting up
    @[Override]
    def startup
      LibGL.clear_color(0.0f32, 0.0f32, 0.0f32, 0.0f32)
      LibGL.front_face(LibGL::CW)
      enable_culling
      LibGL.enable(LibGL::DEPTH_TEST)
      LibGL.enable(LibGL::DEPTH_CLAMP)
      LibGL.enable(LibGL::TEXTURE_2D)
      @shader = Shader::StaticShader.new
      @renderer = Renderer.new(@shader.as(Shader::Program))
      # Uncomment the below line to display everything as a wire frame
      # LibGL.polygon_mode(LibGL::FRONT_AND_BACK, LibGL::LINE)
    end

    # Keep track of the window size at each tick so we can keep the viewport in sync
    @[Override]
    def tick(tick : RenderLoop::Tick, input : RenderLoop::Input)
      @window_size = input.window_size
    end

    # Flush the GL buffers and resize the viewport to match the window size
    # @[Override]
    # def flush
    #   if window_size = @window_size
    #     LibGL.viewport(0, 0, window_size[:width], window_size[:height])
    #   end

    #   LibGL.flush
    # end

    def enable_culling
      LibGL.cull_face(LibGL::BACK)
      LibGL.enable(LibGL::CULL_FACE)
    end

    def disable_culling
      LibGL.disable(LibGL::CULL_FACE)
    end

    def render(entity : Core::Entity)
      LibGL.clear(LibGL::COLOR_BUFFER_BIT | LibGL::DEPTH_BUFFER_BIT)

      # if light = @ambient_light
      #   object.render_all do |transform, material, mesh|
      #     # Lights are a special kind of shader programs.
      #     # We turn on the shader program before drawing the mesh/model
      #     disable_culling if material.has_transparency?
      #     light.as(Light).on(transform, material, self.main_camera)
      #     mesh.draw
      #     light.as(Light).off
      #     enable_culling
      #   end
      # end

      LibGL.enable(LibGL::BLEND)
      LibGL.blend_equation(LibGL::FUNC_ADD)
      LibGL.blend_func(LibGL::ONE, LibGL::ONE_MINUS_SRC_ALPHA)

      LibGL.depth_mask(LibGL::FALSE)
      LibGL.depth_func(LibGL::EQUAL)

      # i = 0
      # while i < @lights.size
      #   object.render_all do |transform, material, mesh|
      #     disable_culling if material.has_transparency?
      #     @lights[i].on(transform, material, self.main_camera)
      #     mesh.draw
      #     @lights[i].off
      #     enable_culling
      #   end
      #   i += 1
      # end

      LibGL.depth_func(LibGL::LESS)
      LibGL.depth_mask(LibGL::TRUE)
      LibGL.disable(LibGL::BLEND)

      r = @renderer.as(Renderer)
      s = @shader.as(Shader::Program)

      shader = @shader.as(Shader::Program)
      shader.start
      # TODO: perhaps the shader uniform configuration here could be put inside of a sub-renderer.
      #  Then we could allow users to create these rendering plugins that are mapped to a specific shader program.
      #  This main rendering engine can sort all of the entities into a hash and then loop
      #  over all of the rendering plugins and hand them the hash.
      #  The rendering plugins can then render those entities it supports.
      #  We might also want to put the gl settings from the startup method in these plugins as well.
      #  This would allow them to tweak things as needed. e.g. there would be some prepare stage and cleanup stage to configure gl stuff.
      shader.projection_matrix = self.main_camera.get_projection
      shader.view_matrix = self.main_camera.get_view
      # TRICKY: for now we only support a single light by default
      shader.light = @lights[0].as(Core::Light)
      shader.eye_pos = self.main_camera.transform.get_transformed_pos
      entity.render_all do |transform, material, mesh|
        shader.material = material
        shader.transformation_matrix = transform.get_transformation
        disable_culling if material.has_transparency?
        mesh.draw
        enable_culling
      end
      shader.stop
    end

    # Registers a light.
    def add_light(light : Core::Light)
      if light.is_a?(Core::AmbientLight)
        @ambient_light = light.as(Core::AmbientLight)
      else
        @lights.push(light)
      end
    end

    # Registers the active camera.
    # Only one camera is supported for now.
    def add_camera(camera : Core::Camera)
      @main_camera = camera
    end

    # Returns the active camera
    @[Raises]
    def main_camera : Camera
      if camera = @main_camera
        return camera
      else
        raise Exception.new "No camera found."
      end
    end

    # Returns which version of OpenGL is available
    def get_open_gl_version
      return String.new(LibGL.get_string(LibGL::VERSION))
    end
  end
end
