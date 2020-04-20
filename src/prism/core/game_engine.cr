require "render_loop"
require "annotation"
require "./entity"

module Prism::Core
  # The game interace.
  # A game must inherit this class in order to be used by the engine.
  abstract class GameEngine < RenderLoop::Engine
    @root : Entity = Entity.new
    @engine : RenderingEngine?
    @entity_engine : EntitySystem::Engine

    def initialize
      @entity_engine = EntitySystem::Engine.new
    end

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
      @entity_engine.add_system EntitySystem::Systems::RenderSystem.new(Shader::StaticShader.new), 1
      tree_entity = EntitySystem::Entity.new("tree")
        .add(EntitySystem::Components::Position.new(0, 0, 0))
      @entity_engine.add_entity(tree_entity)

      self.init
    end

    # Games should implement this to start their game logic
    abstract def init

    # Gives input state to the game
    @[Override]
    def tick(tick : RenderLoop::Tick, input : RenderLoop::Input)
      @entity_engine.update(tick.current_time)
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
