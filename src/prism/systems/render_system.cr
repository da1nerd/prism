require "crash"
require "annotation"
require "./render_system/**"

module Prism::Systems
  # A default system for rendering `Prism::Entity`s.
  class RenderSystem < Crash::System
    @entities : Array(Crash::Entity)
    @lights : Array(Crash::Entity)
    @cameras : Array(Crash::Entity)
    @shader : Prism::Shader::Program
    @grouped_entities : Hash(Prism::TexturedModel, Array(Crash::Entity))
    @renderer : Prism::Systems::Renderer

    def initialize(@shader : Prism::Shader::Program)
      @renderer = Prism::Systems::Renderer.new(@shader)
      @entities = [] of Crash::Entity
      @lights = [] of Crash::Entity
      @cameras = [] of Crash::Entity
      @grouped_entities = {} of Prism::TexturedModel => Array(Crash::Entity)
    end

    @[Override]
    def add_to_engine(engine : Crash::Engine)
      @entities = engine.get_entities Prism::TexturedModel
      # TODO: just get the lights within range
      @lights = engine.get_entities Prism::DirectionalLight
      @cameras = engine.get_entities Prism::Camera
    end

    # Uses the transformation of the *entity* to calculate the view that the camera has of the world.
    # This allows you to attach the camera view to any entity
    def calculate_view_matrix(entity : Crash::Entity)
      transform = entity.get(Prism::Transform).as(Prism::Transform)
      camera_rotation = transform.get_transformed_rot.conjugate.to_rotation_matrix
      camera_pos = transform.get_transformed_pos * -1
      camera_translation = Matrix4f.new.init_translation(camera_pos.x, camera_pos.y, camera_pos.z)
      camera_rotation * camera_translation
    end

    # Sorts the entities into groups of `TexturedModel`s and puts them into @grouped_entities
    def batch_entities(entities : Array(Crash::Entity))
      entities.each do |entity|
        model = entity.get(Prism::TexturedModel).as(Prism::TexturedModel)
        if @grouped_entities.has_key? model
          @grouped_entities[model] << entity
        else
          @grouped_entities[model] = [entity] of Crash::Entity
        end
      end
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

      batch_entities(@entities)

      # calculate camera matricies
      cam_entity = @cameras[0]
      cam = cam_entity.get(Prism::Camera).as(Prism::Camera)
      projection_matrix = cam.get_projection
      view_matrix = calculate_view_matrix(cam_entity)
      eye_pos = cam_entity.get(Prism::Transform).as(Prism::Transform).get_transformed_pos

      # start shading
      @renderer.prepare
      @shader.start
      @shader.projection_matrix = projection_matrix
      @shader.view_matrix = view_matrix
      @shader.eye_pos = eye_pos

      if @lights.size > 0
        light_entity = @lights[0]
        light_transform = light_entity.get(Prism::Transform).as(Prism::Transform)
        @shader.light = light_entity.get(Prism::DirectionalLight).as(Prism::DirectionalLight)
        # TRICKY: this is a temporary hack to help decouple entities from lights.
        #  We'll need a better solution later. We could potentially pass the light
        #  entity to the shader so it can set the proper uniforms.
        @shader.set_uniform("light.direction", light_transform.get_transformed_rot.forward)
      end

      @renderer.render(@grouped_entities)

      @shader.stop
      @grouped_entities.clear
    end

    @[Override]
    def remove_from_engine(engine : Crash::Engine)
      @entities.clear
      @lights.clear
      @cameras.clear
    end
  end
end
