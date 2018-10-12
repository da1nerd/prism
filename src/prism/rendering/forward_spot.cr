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
      super
    end
    
  end
end
