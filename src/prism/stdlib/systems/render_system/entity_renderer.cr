module Prism::Systems
  class EntityRenderer
    @shader : Prism::EntityShader

    def initialize(@shader : Prism::EntityShader)
    end

    # Renders batches of `TexturedModel`s at a time for increased performance
    def render(entities : Hash(Prism::TexturedModel, Array(Crash::Entity)))
      entities.each do |textured_model, batch|
        prepare_textured_model textured_model
        batch.each do |entity|
          prepare_instance entity
          textured_model.model.draw
        end
        unbind_textured_model
      end
    end

    # Prepares the shader before rendering a batch of `TexturedModel`s
    def prepare_textured_model(textured_model : Prism::TexturedModel)
      @shader.diffuse = textured_model.texture
    end

    # Prepares the shader for rendering the actual *entity*
    def prepare_instance(entity : Crash::Entity)
      material = entity.get(Prism::Material).as(Prism::Material)
      model = entity.get(Prism::TexturedModel).as(Prism::TexturedModel)
      disable_culling if material.has_transparency?
      if material.wire_frame?
        disable_culling
        enable_wires
      end
      if entity.has(Prism::TextureOffset)
        # add texture offsetting
        texture_offset = entity.get(Prism::TextureOffset).as(Prism::TextureOffset)
        @shader.number_of_rows = texture_offset.num_rows
        @shader.offset = texture_offset.offset
      else
        # no offset
        @shader.number_of_rows = 1f32
        @shader.offset = Vector2f.new(0, 0)
      end
      @shader.use_fake_lighting = material.use_fake_lighting
      @shader.reflectivity = material.reflectivity
      @shader.shine_damper = material.shine_damper
      transform = entity.get(Prism::Transform).as(Prism::Transform)
      @shader.transformation_matrix = transform.get_transformation
    end

    # Cleans up after rendering a batch of `TexturedModel`s
    def unbind_textured_model
      disable_wires
      enable_culling
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
  end
end
