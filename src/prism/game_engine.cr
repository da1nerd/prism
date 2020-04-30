require "render_loop"
require "annotation"
require "crash"

module Prism
  # The game interace.
  # A game must inherit this class in order to be used by the engine.
  abstract class GameEngine < RenderLoop::Engine
    @root : Entity = Entity.new
    @window_size : RenderLoop::Size?
    @crash_engine : Crash::Engine = Crash::Engine.new

    @[Override]
    def startup
      # configure entity framework
      @crash_engine.add_system Systems::CameraSystem.new, 1
      @crash_engine.add_system Systems::TransformSystem.new, 5
      @crash_engine.add_system Systems::RenderSystem.new, 10

      # pass initialization to the developer
      self.init
    end

    # Games should implement this to start their game logic
    abstract def init

    # Gives input state to the game
    @[Override]
    def tick(tick : RenderLoop::Tick, input : RenderLoop::Input)
      @window_size = input.window_size
      @crash_engine.input(tick, input)
    end

    # Renders the game's scene graph
    @[Override]
    def render
      # TODO: pass in the correct time
      @crash_engine.update(0)
    end

    # Flush the GL buffers and resize the viewport to match the window size
    @[Override]
    def flush
      if window_size = @window_size
        LibGL.viewport(0, 0, window_size[:width], window_size[:height])
      end

      LibGL.flush
    end

    # Adds an object to the game's scene graph.
    def add_entity(entity : Crash::Entity)
      @crash_engine.add_entity entity
    end

    def get_open_gl_version
      return String.new(LibGL.get_string(LibGL::VERSION))
    end
  end
end
