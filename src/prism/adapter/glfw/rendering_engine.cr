require "prism-core"

module Prism::Adapter::GLFW
  class RenderingEngine < Prism::Core::Engine
    @renderer : Prism::RenderingEngine?

    def renderer : Prism::RenderingEngine
      if r = @renderer
        r
      else
        puts "creating new renderer"
        @renderer = Prism::RenderingEngine.new
        @renderer.as(Prism::RenderingEngine)
      end
    end

    def startup
      puts "startup rendering engine"
      self.renderer
    end

    def tick(tick : Prism::Core::Tick, input : Prism::Core::Input)
    end

    def flush
      if renderer = @renderer
        renderer.flush
      end
    end
  end
end
