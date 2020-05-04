module Prism
  # A default game `Engine` with some pre-configured systems.
  abstract class GameEngine < Prism::Engine
    @[Override]
    def startup
      # Register some default systems
      add_system Systems::InputSystem.new, 1
      add_system Systems::RenderSystem.new, 2
      add_system Systems::TerrainSystem.new, 3

      # Initialize the game
      self.init
    end

    @[Override]
    def tick(tick : RenderLoop::Tick, input : RenderLoop::Input)
      super(tick, input)
      # puts "fps: #{1/Math.max(tick.last_actual_frame_time, tick.frame_time)}"
    end
  end
end
