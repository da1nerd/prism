require "crash"
require "annotation"

module Prism::Systems
  # A default system for rendering `Prism::Entity`s.
  class RenderSystem < Crash::System
    @entities : Array(Crash::Entity)
    @lights : Array(Crash::Entity)
    @cameras : Array(Crash::Entity)
    @shader : Prism::Shader::Program
    @grouped_entities : Hash(Prism::TexturedModel, Array(Crash::Entity))

    def initialize(@shader : Prism::Shader::Program)
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
      prepare
    end

    def prepare
      LibGL.clear_color(0.0f32, 0.0f32, 0.0f32, 0.0f32)
      LibGL.front_face(LibGL::CW)
      enable_culling
      LibGL.enable(LibGL::DEPTH_TEST)
      LibGL.enable(LibGL::DEPTH_CLAMP)
      LibGL.enable(LibGL::TEXTURE_2D)
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

    # Prepares the shader before rendering a batch of `TexturedModel`s
    def prepare_textured_model(model : Prism::TexturedModel)
      # TODO: should the vertex attribute arrays be enabled here instead of when the shader starts?
      @shader.material = model.material
      disable_culling if model.material.has_transparency?
      if model.material.wire_frame?
        disable_culling
        enable_wires
      end
    end

    # Prepares the shader for rendering the actual *entity*
    def prepare_instance(entity : Crash::Entity)
      transform = entity.get(Prism::Transform).as(Prism::Transform)
      @shader.transformation_matrix = transform.get_transformation
    end

    # Cleans up after rendering a batch of `TexturedModel`s
    def unbind_textured_model
      # TODO: should the vertex attribute arrays be disabled here instead of when the shader stops?
      disable_wires
      enable_culling
    end

    # Renders batches of `TexturedModel`s at a time for increased performance
    def render(entities : Hash(Prism::TexturedModel, Array(Crash::Entity)))
      entities.each do |model, batch|
        prepare_textured_model model
        batch.each do |entity|
          prepare_instance entity
          model.mesh.draw
        end
        unbind_textured_model
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

      render(@grouped_entities)

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
