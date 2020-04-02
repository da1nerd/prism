require "prism-core"

# TODO: this should be inside a GL namespace.
# This is not tied to GLFW.
# Actually, it would be nice if this wasn't tied to GL either, but was instad fully abstracted
# from the implementations of the rendering engine. It should only receive a generic
# rendering engine class. So this probably shouldn't be in adapters either.
module Prism::Adapter::GLFW
  class GameEngine < Prism::Core::Engine
    def initialize(@game : Prism::Game, @rendering_engine : Prism::RenderingEngine)
    end

    def startup
      @game.engine = @rendering_engine
      @game.init
    end

    def tick(tick : Prism::Core::Tick, input : Prism::Core::Input)
      @game.input(tick.frame_time.to_f32, input)
      @game.update(tick.frame_time.to_f32)
    end

    def render
      @game.render(@rendering_engine)
    end
  end
end
