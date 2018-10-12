require "lib_gl"
require "./shader"
require "./material"

module Prism
  class ForwardDirectional < Shader
    @@instance : ForwardDirectional?

    def initialize
      super("forward-directional")
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
      set_uniform("eyePos", rendering_engine.main_camera.transform.get_transformed_pos)

      set_uniform_directional_light("directionalLight", rendering_engine.active_light.as(DirectionalLight))
    end

    def set_uniform_base_light(name : String, base_light : BaseLight)
      set_uniform(name + ".color", base_light.color)
      set_uniform(name + ".intensity", base_light.intensity)
    end

    def set_uniform_directional_light(name : String, directional_light : DirectionalLight)
      set_uniform_base_light(name + ".base", directional_light)
      set_uniform(name + ".direction", directional_light.direction)
    end
  end
end
