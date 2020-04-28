require "crash"
require "annotation"

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

module Prism::Systems
  # A default system for providing user input to `Prism::Entity`s.
  class InputSystem < Crash::System
    @entities : Array(Crash::Entity)

    def initialize
      @entities = [] of Crash::Entity
    end

    @[Override]
    def add_to_engine(engine : Crash::Engine)
      @entities = engine.get_entities Prism::FreeMove, Prism::FreeLook, Prism::Camera
    end


    @[Override]
    def input(tick : RenderLoop::Tick, input : RenderLoop::Input)
      @entities.each do |e|
        move = e.get(Prism::FreeMove).as(Prism::FreeMove)
        look = e.get(Prism::FreeLook).as(Prism::FreeLook)
        camera = e.get(Prism::Camera).as(Prism::Camera)

        # process input
        move.input(tick, input)
        look.input(tick, input)
        camera.input(tick, input)

        # update entity transform
        # TODO: the move component can return just the movement amount.
        #  Then we can simply add it to the entity instead of overwriting it.
        e.as(Prism::Entity).transform.pos = move.position
      end
    end

    @[Override]
    def remove_from_engine(engine : Crash::Engine)
      @entities.clear
    end
  end
end
