require "lib_gl"
require "./shader"
require "./material"

module Prism

  class ForwardPoint < Shader
    @@instance : ForwardPoint?

    def initialize
      super

      add_vertex_shader_from_file("forward-point.vs")
      add_fragment_shader_from_file("forward-point.fs")

      set_attrib_location("position", 0)
      set_attrib_location("texCoord", 1)
      set_attrib_location("normal", 2)

      compile

      add_uniform("model")
      add_uniform("MVP")

      add_uniform("specularIntensity")
      add_uniform("specularExponent")
      add_uniform("eyePos")

      add_uniform("pointLight.base.color")
      add_uniform("pointLight.base.intensity")
      add_uniform("pointLight.atten.constant")
      add_uniform("pointLight.atten.linear")
      add_uniform("pointLight.atten.exponent")
      add_uniform("pointLight.position")
      add_uniform("pointLight.range")

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
      set_uniform("eyePos", r_engine.main_camera.transform.get_transformed_pos)

      set_uniform_point_light("pointLight", r_engine.active_light.as(PointLight))

    end

    def set_uniform_base_light( name : String, base_light : BaseLight)
      set_uniform(name + ".color", base_light.color)
      set_uniform(name + ".intensity", base_light.intensity)
    end

    def set_uniform_point_light( name : String, point_light : PointLight)
      set_uniform_base_light(name + ".base", point_light)
      set_uniform(name + ".atten.constant", point_light.constant)
      set_uniform(name + ".atten.linear", point_light.linear)
      set_uniform(name + ".atten.exponent", point_light.exponent)
      set_uniform(name + ".position", point_light.transform.get_transformed_pos)
      set_uniform(name + ".range", point_light.range)
    end

  end

end
