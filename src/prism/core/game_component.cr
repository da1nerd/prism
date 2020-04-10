require "render_loop"

module Prism::Core
  # A game component is an enhancement that can be added to a game object
  abstract class GameComponent
    setter parent

    @parent : GameObject = GameObject.new

    def input(tick : RenderLoop::Tick, input : RenderLoop::Input)
    end

    def update(tick : RenderLoop::Tick)
    end

    # Renders the component
    #
    # > Warning: the *rendering_engine* property will be deprecated in the future
    def render(light : Light, rendering_engine : RenderingEngine)
    end

    def add_to_engine(engine : RenderingEngine)
    end

    def transform : Transform
      @parent.transform
    end
  end
end
