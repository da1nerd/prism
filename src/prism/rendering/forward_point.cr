require "lib_gl"
require "./shader"
require "./material"

module Prism
  class ForwardPoint < Shader
    @@instance : ForwardPoint?

    def initialize
      super("forward-point")
    end

    def self.instance
      @@instance ||= new
    end

    def update_uniforms(transform : Transform, material : Material, rendering_engine : RenderingEngineProtocol)
      super
    end
  end
end
