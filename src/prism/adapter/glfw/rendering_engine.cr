require "prism-core"

module Prism::Adapter::GLFW
  class RenderingEngine < Prism::Core::Engine
    @renderer : Prism::RenderingEngine?
    @window_size : NamedTuple(height: Int32, width: Int32)?

    def renderer : Prism::RenderingEngine
      if r = @renderer
        r
      else
        @renderer = Prism::RenderingEngine.new
        @renderer.as(Prism::RenderingEngine)
      end
    end

    def startup
      self.renderer
    end

    def tick(tick : Prism::Core::Tick, input : Prism::Core::Input)
      # keep track of the window size so we can adjust the viewport during render
      @window_size = input.window_size
    end

    def render
      # Adjust the viewport to match the window size
      if window_size = @window_size
        LibGL.viewport(0, 0, window_size[:width], window_size[:height])
      end
    end

    def flush
      if renderer = @renderer
        renderer.flush
      end
    end
  end
end
