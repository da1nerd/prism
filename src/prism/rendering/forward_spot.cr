require "lib_gl"
require "./shader"

module Prism
  class ForwardSpot < Shader
    @@instance : ForwardSpot?

    def initialize
      super("forward-spot")
    end

    def self.instance
      @@instance ||= new
    end

    def update_uniforms(transform : Transform, material : Material, rendering_engine : RenderingEngineProtocol)
      world_matrix = transform.get_transformation
      projected_matrix = rendering_engine.main_camera.get_view_projection * world_matrix

      material.get_texture("diffuse").bind

      set_uniform("model", world_matrix)
      set_uniform("MVP", projected_matrix)

      set_uniform("specularIntensity", material.get_float("specularIntensity"))
      set_uniform("specularExponent", material.get_float("specularPower"))
      set_uniform("C_eyePos", rendering_engine.main_camera.transform.get_transformed_pos)

      set_uniform_spot_light("spotLight", rendering_engine.active_light.as(SpotLight))
    end

    def set_uniform_base_light(name : String, base_light : BaseLight)
      set_uniform(name + ".color", base_light.color)
      set_uniform(name + ".intensity", base_light.intensity)
    end

    def set_uniform_point_light(name : String, point_light : PointLight)
      set_uniform_base_light(name + ".base", point_light)
      set_uniform(name + ".atten.constant", point_light.constant)
      set_uniform(name + ".atten.linear", point_light.linear)
      set_uniform(name + ".atten.exponent", point_light.exponent)
      set_uniform(name + ".position", point_light.transform.get_transformed_pos)
      set_uniform(name + ".range", point_light.range)
    end

    def set_uniform_spot_light(name : String, spot_light : SpotLight)
      set_uniform_point_light(name + ".pointLight", spot_light)
      set_uniform(name + ".direction", spot_light.direction)
      set_uniform(name + ".cutoff", spot_light.cutoff)
    end
  end
end
