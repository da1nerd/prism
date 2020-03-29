require "prism-core"

module Prism::Adapter::GLFW
  class RenderingEngine < Prism::Core::Engine
    def initialize
      @renderer = Prism::RenderingEngine.new
    end

    def tick(tick : Prism::Core::Tick, input : Prism::Core::Input)
    end

    def flush
      @renderer.flush
    end
  end
end
