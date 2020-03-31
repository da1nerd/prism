require "prism-core"
require "crystglfw"

module Prism
  # inject the adapter into the top namespace
  include Adapter::GLFW
end

module Prism::Adapter::GLFW
  extend self

  def run(title : String, game : Prism::Game)
    run(title, game, frame_rate, 60, 800, 600)
  end

  def run(title : String, game : Prism::Game, frame_rate : Float64 = 60)
    run(title, game, frame_rate, 800, 600)
  end

  # Starts Prism.
  # This automatically adds the standard rendering engine
  def run(title : String, game : Prism::Game, frame_rate : Float64, width : Int32, height : Int32)
    rendering_engine = Prism::Adapter::GLFW::RenderingEngine.new
    game_engine = GLFW::GameEngine.new(game, rendering_engine)
    engines = [game_engine.as(Prism::Core::Engine)] # , rendering_engine]

    harness = Prism::Core::LoopHarness.new(frame_rate, engines)
    CrystGLFW.run do
      window = GLFW::Window.new(title: title, width: width, height: height)
      window.startup # TODO: this is a temporary hack. The startup method should be called when the harness starts.

      harness.on_tick do
        CrystGLFW.poll_events
      end

      harness.start(window)
    end
  end
end
