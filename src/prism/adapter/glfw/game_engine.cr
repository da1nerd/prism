require "prism-core"

module Prism::Adapter::GLFW
  class GameEngine < Prism::Core::Engine
    def initialize(@game : Prism::Game, @rendering_engine : Prism::Adapter::GLFW::RenderingEngine)
    end

    def startup
      @game.engine = @rendering_engine.renderer
      @game.init
    end

    def tick(tick : Prism::Core::Tick, input : Prism::Core::Input)
      @game.input(tick.frame_time.to_f32, input)
      @game.update(tick.frame_time.to_f32)
    end

    def render
      if renderer = @rendering_engine.renderer
        @game.render(renderer)
      end
    end
  end
end
