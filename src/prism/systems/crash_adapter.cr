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
  end

  abstract class System
    # Extend `Crash::System` with an input method
    def input(tick : RenderLoop::Tick, input : RenderLoop::Input); end
  end
end
