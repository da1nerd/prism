require "render_loop"
require "crystglfw"

# An adapter for the GLFW rendering context.
module Prism::Adapter::GLFW
  extend self

  def run(title : String, game : Prism::GameEngine)
    run(title, game, frame_rate, 60, 800, 600)
  end

  def run(title : String, game : Prism::GameEngine, frame_rate : Float64 = 60)
    run(title, game, frame_rate, 800, 600)
  end

  # Starts up the game engine
  def run(title : String, game : Prism::GameEngine, frame_rate : Float64, width : Int32, height : Int32)
    harness = RenderLoop::LoopHarness.new(frame_rate, [game] of RenderLoop::Engine)
    CrystGLFW.run do
      window = GLFW::Window.new(title: title, width: width, height: height)

      harness.on_tick do
        CrystGLFW.poll_events
      end

      harness.start(window)
    end
  end
end
