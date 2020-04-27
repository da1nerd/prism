require "render_loop"
require "crash"

module Prism
  # A game component is an enhancement that can be added to a game object
  abstract class Component < Crash::Component
    setter parent

    @parent : Entity = Entity.new

    def input(tick : RenderLoop::Tick, input : RenderLoop::Input)
    end

    def update(tick : RenderLoop::Tick)
    end

    def transform : Transform
      @parent.transform
    end
  end
end
