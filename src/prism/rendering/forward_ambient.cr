require "lib_gl"
require "./shader"
require "./material"

module Prism

  class ForwardAmbient < Shader
    @@instance : ForwardAmbient?

    def initialize
      super

      vertex_shader_text = load_shader("forward-ambient.vs")
      fragment_shader_text = load_shader("forward-ambient.fs")

      add_vertex_shader(vertex_shader_text)
      add_fragment_shader(fragment_shader_text)

      add_all_attributes(vertex_shader_text)

      compile

      add_all_uniforms(vertex_shader_text)
      add_all_uniforms(fragment_shader_text)
    end

    def self.instance
      @@instance ||= new
    end

    def update_uniforms(transform : Transform, material : Material, rendering_engine : RenderingEngineProtocol)

      world_matrix = transform.get_transformation
      projected_matrix = rendering_engine.main_camera.get_view_projection * world_matrix

      material.get_texture("diffuse").bind

      set_uniform("MVP", projected_matrix)
      set_uniform("ambientIntensity", rendering_engine.ambient_light)
    end
  end

end
