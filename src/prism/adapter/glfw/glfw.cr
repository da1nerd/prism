require "render_loop"
require "crystglfw"

# TODO: this should be under a Prism::Context::GLFW namespace
# since this is setting up the context in which the game will run.
module Prism::Adapter::GLFW
  extend self

  def run(title : String, game : Core::GameEngine)
    run(title, game, frame_rate, 60, 800, 600)
  end

  def run(title : String, game : Core::GameEngine, frame_rate : Float64 = 60)
    run(title, game, frame_rate, 800, 600)
  end

  # Starts Prism.
  # This automatically adds the standard rendering engine
  def run(title : String, game : Core::GameEngine, frame_rate : Float64, width : Int32, height : Int32)
    rendering_engine = Core::RenderingEngine.new
    game.engine = rendering_engine
    engines = [game, rendering_engine]

    harness = RenderLoop::LoopHarness.new(frame_rate, engines)
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

module Prism
  # inject the adapter into the top namespace
  include Adapter::GLFW
end
