module Crash
  class Engine
    # Extend the `Crash::Engine` with an input method
    def input(tick : RenderLoop::Tick, input : RenderLoop::Input)
      @updating = true
      @systems.each do |system|
        system.input(tick, input)
      end
      @updating = false
      emit UpdateCompleteEvent
    end

    # Extend the `Crash::Engine` with a render method
    def render
      @updating = true
      @systems.each do |system|
        system.render
      end
      @updating = false
      emit UpdateCompleteEvent
    end
  end

  abstract class System
    # Extend `Crash::System` with an input method
    def input(tick : RenderLoop::Tick, input : RenderLoop::Input); end

    # Extend `Crash::System` with a render method
    def render; end
  end
end
