require "render_loop"
require "annotation"
require "crash"
require "./core/clock"

module Prism
  # The main engine to run the game.
  # You can implement your game engine by inheriting this class and adding your logic.
  abstract class Engine < RenderLoop::Engine
    @window_size : RenderLoop::Size?
    @crash_engine : Crash::Engine = Crash::Engine.new

    # Starts up the engine.
    @[Override]
    def startup
      self.init
    end

    # Games should implement this to start their game logic
    abstract def init

    # Process inputs
    # This will pass time and input to the engine systems.
    @[Override]
    def tick(tick : RenderLoop::Tick, input : RenderLoop::Input)
      Prism::Core::Clock.tick(tick.frame_time)
      # get window size so we can adjust the viewport during flush
      @window_size = input.window_size
      @crash_engine.input(tick, input)
    end

    # Renders the game
    @[Override]
    def render
      @crash_engine.render
    end

    # Flush the GL buffers and resize the viewport to match the window size
    @[Override]
    def flush
      if window_size = @window_size
        LibGL.viewport(0, 0, window_size[:width], window_size[:height])
      end

      LibGL.flush
    end

    # Adds an entity to the entity engine
    def add_entity(entity : Crash::Entity)
      @crash_engine.add_entity entity
    end

    # Adds a system to the entity engine
    def add_system(system : Crash::System, priority : Int32)
      @crash_engine.add_system system, priority
    end

    def get_open_gl_version
      return String.new(LibGL.get_string(LibGL::VERSION))
    end
  end
end
