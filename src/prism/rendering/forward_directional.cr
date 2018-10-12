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
    end
  end
end
