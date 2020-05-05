module Prism::Systems
  # TODO: move this into stdlib
  class EntityRenderer
    @shader : Prism::EntityShader

    def initialize(@shader : Prism::EntityShader)
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

    # Prepares the shader before rendering a batch of `TexturedModel`s
    def prepare_textured_model(model : Prism::TexturedModel)
      # TODO: should the vertex attribute arrays be enabled here instead of when the shader starts?
      @shader.texture = model.texture
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
      # Enable texture offseting for single textures.
      # TODO: this could probably be made more generic so we support everything inside the texture pack.
      if model.texture.textures.size == 1 && model.texture.textures.values[0].atlas.size > 1
        @shader.number_of_rows = model.texture.textures.values[0].atlas.size.to_f32
        if entity.has(Prism::TextureAtlasIndex)
          atlas_index = entity.get(Prism::TextureAtlasIndex).as(Prism::TextureAtlasIndex)
          coords = model.texture.textures.values[0].atlas.get_coords atlas_index.index
          @shader.offset = coords[:top_right]
        else
          raise "#{entity.name} uses a TextureAtlas but does not have a TextureAtlasIndex. You must specify the index."
        end
      else
        @shader.number_of_rows = 1f32
        @shader.offset = Vector2f.new(0, 0)
      end
      @shader.use_fake_lighting = material.use_fake_lighting
      @shader.specular_intensity = material.specular_intensity
      @shader.specular_power = material.specular_power
      transform = entity.get(Prism::Transform).as(Prism::Transform)
      @shader.transformation_matrix = transform.get_transformation
    end

    # Cleans up after rendering a batch of `TexturedModel`s
    def unbind_textured_model
      # TODO: should the vertex attribute arrays be disabled here instead of when the shader stops?
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
