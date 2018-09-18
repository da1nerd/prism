require "./shader"
require "./resource_loader"
require "./material"
require "./render_util"

module Prism

  class BasicShader < Shader

    def initialize
      super

      add_vertex_shader(ResourceLoader.load_shader("basicVertex.vs"))
      add_fragment_shader(ResourceLoader.load_shader("basicFragment.fs"))
      compile

      add_uniform("transform")
      add_uniform("color")
    end


    def update_uniforms(world_matrix : Matrix4f, projected_matrix : Matrix4f, material : Material)
      if material.texture
        material.texture.bind
      else
        RenderUtil.unbind_textures
      end

      set_uniform("transform", projected_matrix)
      set_uniform("color", material.color)
    end
  end
end