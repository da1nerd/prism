require "lib_gl"
require "./shader"

module Prism

  class ForwardDirectional < Shader
    @@instance : ForwardDirectional?

    def initialize
      super

      add_vertex_shader_from_file("forward-directional.vs")
      add_fragment_shader_from_file("forward-directional.fs")

      set_attrib_location("position", 0)
      set_attrib_location("texCoord", 1)
      set_attrib_location("normal", 2)

      compile

      add_uniform("model")
      add_uniform("MVP")

      add_uniform("specularIntensity")
      add_uniform("specularExponent")
      add_uniform("eyePos")

      add_uniform("directionalLight.base.color")
      add_uniform("directionalLight.base.intensity")
      add_uniform("directionalLight.direction")
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

      set_uniform("model", world_matrix)
      set_uniform("MVP", projected_matrix)

      set_uniform("specularIntensity", material.specular_intensity)
      set_uniform("specularExponent", material.specular_exponent)
      set_uniform("eyePos", r_engine.main_camera.pos)

      set_uniform("directionalLight", r_engine.directional_light)

    end

    def set_uniform( name : String, base_light : BaseLight)
      set_uniform(name + ".color", base_light.color)
      set_uniform(name + ".intensity", base_light.intensity)
    end

    def set_uniform( name : String, directional_light : DirectionalLight)
      set_uniform(name + ".base", directional_light.base)
      set_uniform(name + ".direction", directional_light.direction)
    end

  end

end
