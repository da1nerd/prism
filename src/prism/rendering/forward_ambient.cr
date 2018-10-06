require "lib_gl"
require "./shader"
require "./material"

module Prism

  class ForwardAmbient < Shader
    @@instance : ForwardAmbient?

    def initialize
      super

      add_vertex_shader_from_file("forward-ambient.vs")
      add_fragment_shader_from_file("forward-ambient.fs")

      set_attrib_location("position", 0)
      set_attrib_location("texCoord", 1)

      compile

      add_uniform("MVP")
      add_uniform("ambientIntensity")
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

      set_uniform("MVP", projected_matrix)
      set_uniform("ambientIntensity", r_engine.ambient_light)
    end
  end

end
