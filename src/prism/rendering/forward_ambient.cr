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
      super
    end
  end
end
