require "crash"
require "annotation"

module Prism::Systems
  # A default system for providing user input to `Prism::Entity`s.
  class TransformSystem < Crash::System
    @entities : Array(Crash::Entity)

    def initialize
      @entities = [] of Crash::Entity
    end

    @[Override]
    def add_to_engine(engine : Crash::Engine)
      # TODO: change this to look for a transform. Then rename this system
      @entities = engine.get_entities Prism::Transform
    end

    @[Override]
    def input(tick : RenderLoop::Tick, input : RenderLoop::Input)
      puts "fps: #{1/Math.max(tick.last_actual_frame_time, tick.frame_time)}"
      @entities.each do |e|
        e.get(Prism::Transform).as(Prism::Transform).update
        transform = e.get(Prism::Transform).as(Prism::Transform)

        if e.has Prism::FreeLook
          move = e.get(Prism::FreeMove).as(Prism::FreeMove)
          move.input(tick, input, transform)
          transform.pos = move.position
        end

        if e.has Prism::FreeLook
          look = e.get(Prism::FreeLook).as(Prism::FreeLook)
          look.input!(tick, input, transform)
        end
      end
    end

    @[Override]
    def remove_from_engine(engine : Crash::Engine)
      @entities.clear
    end
  end
end
