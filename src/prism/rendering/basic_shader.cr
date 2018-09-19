require "./shader"
require "./material"

module Prism

  class BasicShader < Shader

    @@instance : BasicShader?

    def initialize
      super

      add_vertex_shader_from_file("basicVertex.vs")
      add_fragment_shader_from_file("basicFragment.fs")
      compile

      add_uniform("transform")
      add_uniform("color")
    end

    def self.instance
      @@instance ||= new
    end

    def update_uniforms(world_matrix : Matrix4f, projected_matrix : Matrix4f, material : Material)
      material.texture.bind

      set_uniform("transform", projected_matrix)
      set_uniform("color", material.color)
    end
  end
end
