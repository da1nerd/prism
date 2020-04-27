require "crash"
require "annotation"

module Prism::Core
  class RenderSystem < Crash::System
    @entities : Array(Crash::Entity)
    @lights : Array(Crash::Entity)
    @cameras : Array(Crash::Entity)
    @shader : Core::Shader::Program

    def initialize(@shader : Core::Shader::Program, @camera : Core::Camera)
      @entities = [] of Crash::Entity
      @lights = [] of Crash::Entity
      @cameras = [] of Crash::Entity
    end

    @[Override]
    def add_to_engine(engine : Crash::Engine)
      @entities = engine.get_entities Prism::Core::Material, Prism::Core::Mesh, Prism::Core::Transform
      # TODO: just get the lights within range
      @lights = engine.get_entities Prism::Core::Light
      @cameras = engine.get_entities Prism::Core::Camera
      prepare
    end

    def prepare
      LibGL.clear_color(0.0f32, 0.0f32, 0.0f32, 0.0f32)
      LibGL.front_face(LibGL::CW)
      enable_culling
      LibGL.enable(LibGL::DEPTH_TEST)
      LibGL.enable(LibGL::DEPTH_CLAMP)
      LibGL.enable(LibGL::TEXTURE_2D)
      # @shader = Shader::StaticShader.new
      # @renderer = Renderer.new(@shader.as(Shader::Program))
      # Uncomment the below line to display everything as a wire frame
      # LibGL.polygon_mode(LibGL::FRONT_AND_BACK, LibGL::LINE)
    end

    def enable_culling
      LibGL.cull_face(LibGL::BACK)
      LibGL.enable(LibGL::CULL_FACE)
    end

    def disable_culling
      LibGL.disable(LibGL::CULL_FACE)
    end

    @[Override]
    def update(time : Float64)
      LibGL.clear(LibGL::COLOR_BUFFER_BIT | LibGL::DEPTH_BUFFER_BIT)

      LibGL.enable(LibGL::BLEND)
      LibGL.blend_equation(LibGL::FUNC_ADD)
      LibGL.blend_func(LibGL::ONE, LibGL::ONE_MINUS_SRC_ALPHA)

      LibGL.depth_mask(LibGL::FALSE)
      LibGL.depth_func(LibGL::EQUAL)

      LibGL.depth_func(LibGL::LESS)
      LibGL.depth_mask(LibGL::TRUE)
      LibGL.disable(LibGL::BLEND)

      main_camera = @cameras[0].get(Core::Camera).as(Core::Camera)
      @shader.start
      @shader.projection_matrix = main_camera.get_projection
      @shader.view_matrix = main_camera.get_view
      @shader.light = @lights[0].get(Core::Light).as(Core::Light) if @lights.size > 0
      @shader.eye_pos = main_camera.transform.get_transformed_pos
      @entities.each do |entity|
        material = entity.get(Prism::Core::Material).as(Prism::Core::Material)
        transform = entity.get(Prism::Core::Transform).as(Prism::Core::Transform)
        @shader.material = material
        @shader.transformation_matrix = transform.get_transformation
        disable_culling if material.has_transparency?
        puts "drawing #{entity.name}"
        entity.get(Prism::Core::Mesh).as(Prism::Core::Mesh).draw
        enable_culling
      end
      @shader.stop
    end

    @[Override]
    def remove_from_engine(engine : Crash::Engine)
      @entities.clear
      @lights.clear
      @cameras.clear
    end
  end
end
