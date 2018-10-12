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
      super
      # world_matrix = transform.get_transformation
      # projected_matrix = rendering_engine.main_camera.get_view_projection * world_matrix

      # material.get_texture("diffuse").bind

      # set_uniform("model", world_matrix)
      # set_uniform("MVP", projected_matrix)

      # set_uniform("specularIntensity", material.get_float("specularIntensity"))
      # set_uniform("specularExponent", material.get_float("specularPower"))
      # set_uniform("eyePos", rendering_engine.main_camera.transform.get_transformed_pos)

      # set_uniform_directional_light("directionalLight", rendering_engine.active_light.as(DirectionalLight))
    end


  end
end
