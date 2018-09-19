require "./shader"
require "./material"
require "../core/transform"

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

    def update_uniforms(transform : Transform, material : Material)
      r_engine = rendering_engine
      unless r_engine
        puts "Error: The rendering engine was not configured."
        exit 1
      end

      world_matrix = transform.get_transformation
      projected_matrix = r_engine.main_camera.get_view_projection * world_matrix

      material.texture.bind

      set_uniform("transform", projected_matrix)
      set_uniform("color", material.color)
    end
  end
end
