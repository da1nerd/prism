require "crash"
require "annotation"

module Prism::Systems
  # A default system for providing user input to `Prism::Entity`s.
  # TODO: This should probably be changed back to InputSystem.
  #  The input system will get those entities that have an input component
  #  and then run through some operations.
  #  Maybe the input component could specify which components it needs to operate on
  #  Then this system could dynamically provide those components if avaiable.
  #  The InputComponent could then pass input to the specified components for processing.
  #  So the InputComponent would simply act as a router to get input into other components.
  #  Maybe we could pass the entity to the components that receive an input.
  #  e.g. `component.input(tick, input, entity)` This would allow components to perform their own logic and access other components.
  #  we can check to see if this method exists. If it does not we should log a warning.
  class TransformSystem < Crash::System
    @entities : Array(Crash::Entity)

    def initialize
      @entities = [] of Crash::Entity
    end

    @[Override]
    def add_to_engine(engine : Crash::Engine)
      @entities = engine.get_entities Prism::Transform
    end

    @[Override]
    def input(tick : RenderLoop::Tick, input : RenderLoop::Input)
      puts "fps: #{1/Math.max(tick.last_actual_frame_time, tick.frame_time)}"
      @entities.each do |e|
        e.get(Prism::Transform).as(Prism::Transform).update
        transform = e.get(Prism::Transform).as(Prism::Transform)

        if e.has Prism::FreeMove
          move = e.get(Prism::FreeMove).as(Prism::FreeMove)
          move.input(tick, input, transform)
          transform.pos = move.position
        end

        if e.has Prism::FreeLook
          look = e.get(Prism::FreeLook).as(Prism::FreeLook)
          look.input!(tick, input, transform)
        end

        if e.has Prism::Player
          player = e.get(Prism::Player).as(Prism::Player)
          player.input!(tick, input, transform)
        end
      end
    end

    @[Override]
    def remove_from_engine(engine : Crash::Engine)
      @entities.clear
    end
  end
end
