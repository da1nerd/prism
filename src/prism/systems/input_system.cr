require "crash"
require "annotation"

module Prism::Systems
  # Passes input events to the `InputDispatcher`
  class InputSystem < Crash::System
    @entities : Array(Crash::Entity)

    def initialize
      @entities = [] of Crash::Entity
    end

    @[Override]
    def add_to_engine(engine : Crash::Engine)
      @entities = engine.get_entities Prism::InputDispatcher
    end

    @[Override]
    def input(tick : RenderLoop::Tick, input : RenderLoop::Input)
      @entities.each do |e|
        e.get(Prism::InputDispatcher).as(Prism::InputDispatcher).input!(tick, input, e)
      end
    end

    @[Override]
    def remove_from_engine(engine : Crash::Engine)
      @entities.clear
    end
  end
end
