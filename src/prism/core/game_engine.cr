require "render_loop"
require "annotation"
require "crash"
require "./entity"

module Prism::Core
  # The game interace.
  # A game must inherit this class in order to be used by the engine.
  abstract class GameEngine < RenderLoop::Engine
    @root : Entity = Entity.new
    @engine : RenderingEngine?
    @crash_engine : Crash::Engine = Crash::Engine.new

    # Returns the registered `GameEngine` or throw an exception.
    # The engine must be assigned before the game loop starts.
    @[Raises]
    def engine : RenderingEngine
      if @engine.nil?
        raise Exception.new "No RenderingEngine defined. Use #engine= to assign an engine before starting the game loop"
      end
      @engine.as(RenderingEngine)
    end

    @[Override]
    def startup
      # configure entity framework
      # TODO: add more systems here
      @crash_engine.add_system RenderSystem.new, 10

      # pass initialization to the developer
      self.init
    end

    def add_entity(entity : Crash::Entity)
      @crash_engine.add_entity entity
    end

    # Games should implement this to start their game logic
    abstract def init

    # Gives input state to the game
    @[Override]
    def tick(tick : RenderLoop::Tick, input : RenderLoop::Input)
      @crash_engine.update(tick.current_time)
      @root.input_all(tick, input)
      @root.update_all(tick)
    end

    # Renders the game's scene graph
    @[Override]
    def render
      self.engine.render(@root)
    end

    # Adds an object to the game's scene graph.
    def add_object(object : Entity)
      @root.add_child(object)
    end

    # Registers the `engine` with the game
    def engine=(@engine : RenderingEngine)
      @root.engine = @engine.as(RenderingEngine)
    end
  end
end
