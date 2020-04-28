require "crash"
require "annotation"

module Prism::Systems
  # A default system for providing user input to `Prism::Entity`s.
  class CameraSystem < Crash::System
    @entities : Array(Crash::Entity)

    def initialize
      @entities = [] of Crash::Entity
    end

    @[Override]
    def add_to_engine(engine : Crash::Engine)
      @entities = engine.get_entities Prism::Camera
    end


    @[Override]
    def input(tick : RenderLoop::Tick, input : RenderLoop::Input)
      @entities.each do |e|
        e.get(Prism::Camera).as(Prism::Camera).input(tick, input)
      end
    end

    @[Override]
    def remove_from_engine(engine : Crash::Engine)
      @entities.clear
    end
  end
end
