require "lib_gl"
require "./shader"
require "./material"

module Prism

  class ForwardAmbient < Shader
    @@instance : ForwardAmbient?

    def initialize
      super("forward-ambient")
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
