module Prism::Systems
  # TODO: move this into stdlib
  class TerrainRenderer
    def initialize(@shader : Prism::Shader::TerrainShader)
    end

    # Renders batches of `TexturedModel`s at a time for increased performance
    def render(terrains : Array(Crash::Entity))
      terrains.each do |entity|
        terrain = entity.get(Prism::Terrain).as(Prism::Terrain)
        prepare_terrain entity
        load_model_matrix terrain.transform
        terrain.model.mesh.draw
        unbind_textured_model
      end
    end

    # Prepares the shader before rendering a batch of `TexturedModel`s
    def prepare_terrain(entity : Crash::Entity)
      material = entity.get(Prism::Material).as(Prism::Material)
      terrain = entity.get(Prism::Terrain).as(Prism::Terrain)
      # TODO: should the vertex attribute arrays be enabled here instead of when the shader starts?
      @shader.texture = terrain.model.texture
      disable_culling if material.has_transparency?
      if material.wire_frame?
        disable_culling
        enable_wires
      end
    end

    # Prepares the shader for rendering the actual *entity*
    def load_model_matrix(transform : Prism::Transform)
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
