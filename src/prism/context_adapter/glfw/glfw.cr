require "render_loop"
require "crystglfw"

# An adapter for the GLFW rendering context.
module Prism::ContextAdapter::GLFW
  extend self

  def run(title : String, game : Core::GameEngine)
    run(title, game, frame_rate, 60, 800, 600)
  end

  def run(title : String, game : Core::GameEngine, frame_rate : Float64 = 60)
    run(title, game, frame_rate, 800, 600)
  end

  # Starts up `Prism`.
  # This automatically adds the standard `RenderingEngine` and attaches it to the `GameEngine`.
  def run(title : String, game : Core::GameEngine, frame_rate : Float64, width : Int32, height : Int32)
    rendering_engine = Core::RenderingEngine.new
    game.engine = rendering_engine
    engines = [game, rendering_engine]

    harness = RenderLoop::LoopHarness.new(frame_rate, engines)
    CrystGLFW.run do
      window = GLFW::Window.new(title: title, width: width, height: height)

      harness.on_tick do
        CrystGLFW.poll_events
      end

      harness.start(window)
    end
  end
end

module Prism
  # inject the adapter into the top namespace so we can easily access the `GLFW::Window`
  include ContextAdapter::GLFW
end
