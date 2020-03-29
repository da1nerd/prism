require "prism-core"
require "crystglfw"

module Prism::Adapter::GLFW
  extend self

  def run(title : String, engines : Array(Prism::Core::Engine))
    run(title, engines, frame_rate, 60, 800, 600)
  end

  def run(title : String, engines : Array(Prism::Core::Engine), frame_rate : Float64 = 60)
    run(title, engines, frame_rate, 800, 600)
  end

  # Starts Prism.
  # This automatically adds the standard rendering engine
  def run(title : String, engines : Array(Prism::Core::Engine), frame_rate : Float64, width : Int32, height : Int32)
    engines << Prism::Adapter::GLFW::RenderingEngine.new
    harness = Prism::Core::LoopHarness.new(frame_rate, engines)
    CrystGLFW.run do
      window = GLFW::Window.new(title: title, width: width, height: height)

      harness.on_tick do
        CrystGLFW.poll_events
      end

      harness.on_render do
        # Adjust the viewport to match the window size
        LibGL.viewport(0, 0, window.size[:width], window.size[:height])
      end

      harness.start(window)
    end
  end
end
