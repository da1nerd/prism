require "render_loop"

module Prism::Core
  # A game component is an enhancement that can be added to a game object
  abstract class GameComponent
    setter parent

    @parent : Core::GameObject = Core::GameObject.new

    def input(tick : RenderLoop::Tick, input : RenderLoop::Input)
    end

    def update(tick : RenderLoop::Tick)
    end

    # Renders the component
    #
    # > Warning: the *rendering_engine* property will be deprecated in the future
    def render(&block : RenderCallback)
    end

    def add_to_engine(engine : Core::RenderingEngine)
    end

    def transform : Core::Transform
      @parent.transform
    end
  end
end
