require "crash"
require "annotation"

module Prism::Systems
  # A rudimentary collision detection system for the terrain.
  # This should run after the `InputSystem`
  class TerrainSystem < Crash::System
    @entities : Array(Crash::Entity)
    @terrain : Array(Crash::Entity)

    def initialize
      @entities = [] of Crash::Entity
      @terrain = [] of Crash::Entity
    end

    @[Override]
    def add_to_engine(engine : Crash::Engine)
        @terrain = engine.get_entities Prism::Terrain
        @entities = engine.get_entities Prism::PlayerMovement
    end

    @[Override]
    def input(tick : RenderLoop::Tick, input : RenderLoop::Input)
        if @terrain.size == 1
            @entities.each do |e|
                e.get(Prism::PlayerMovement).as(Prism::PlayerMovement).detect_terrain!(e, @terrain[0])
            end
        else
            raise Exception.new("Woops! The terrain system currently requires a single terrain.")
        end
    end

    @[Override]
    def remove_from_engine(engine : Crash::Engine)
      @entities.clear
      @terrain.clear
    end
  end
end
