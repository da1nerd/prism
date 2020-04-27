require "crash"
require "annotation"

module Prism::Systems
  # A default system for rendering `Prism::Entity`s.
  class RenderSystem < Crash::System
    @entities : Array(Crash::Entity)
    @lights : Array(Crash::Entity)
    @cameras : Array(Crash::Entity)
    @shader : Prism::Shader::Program

    def initialize(@shader : Prism::Shader::Program)
      @entities = [] of Crash::Entity
      @lights = [] of Crash::Entity
      @cameras = [] of Crash::Entity
    end

    @[Override]
    def add_to_engine(engine : Crash::Engine)
      @entities = engine.get_entities Prism::Material, Prism::Mesh, Prism::Transform
      # TODO: just get the lights within range
      @lights = engine.get_entities Prism::DirectionalLight
      @cameras = engine.get_entities Prism::Camera
      prepare
    end

    def prepare
      LibGL.clear_color(0.0f32, 0.0f32, 0.0f32, 0.0f32)
      LibGL.front_face(LibGL::CW)
      enable_culling
      LibGL.enable(LibGL::DEPTH_TEST)
      LibGL.enable(LibGL::DEPTH_CLAMP)
      LibGL.enable(LibGL::TEXTURE_2D)
      # Uncomment the below line to display everything as a wire frame
      # LibGL.polygon_mode(LibGL::FRONT_AND_BACK, LibGL::LINE)
    end

    def enable_wires
      LibGL.polygon_mode(LibGL::FRONT_AND_BACK, LibGL::LINE)
    end

    def disable_wires
      LibGL.polygon_mode(LibGL::FRONT_AND_BACK, LibGL::FILL)
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

      main_camera = @cameras[0].get(Prism::Camera).as(Prism::Camera)
      @shader.start
      @shader.projection_matrix = main_camera.get_projection
      @shader.view_matrix = main_camera.get_view
      @shader.light = @lights[0].get(Prism::DirectionalLight).as(Prism::DirectionalLight) # if @lights.size > 0
      @shader.eye_pos = main_camera.transform.get_transformed_pos
      @entities.each do |entity|
        material = entity.get(Prism::Material).as(Prism::Material)
        transform = entity.get(Prism::Transform).as(Prism::Transform)
        @shader.material = material
        @shader.transformation_matrix = transform.get_transformation
        disable_culling if material.has_transparency?
        if material.wire_frame?
          disable_culling
          enable_wires
        end
        entity.get(Prism::Mesh).as(Prism::Mesh).draw
        disable_wires
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
