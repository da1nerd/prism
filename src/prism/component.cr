require "render_loop"
require "crash"

module Prism
  # A game component is an enhancement that can be added to a game object
  # DEPRECATED This is holding together most of the code at the moment, but this will eventually be removed.
  abstract class Component < Crash::Component
    # DEPRECATED the components shouldn't have direct access to their parent.
    setter parent
    @parent : Prism::Entity = Prism::Entity.new

    # Receives input between frames
    # TODO: this should be triggered by a system
    # DEPRECATED components that need an input method should implement it and then use a custom system
    def input(tick : RenderLoop::Tick, input : RenderLoop::Input)
    end

    # Receives update events between frames
    # TODO: this should be triggered by a system
    # DEPRECATED components that need an update method should implement it and then use a custom system
    def update(tick : RenderLoop::Tick)
    end

    # Receives it's transformation from it's parent `Entity`.
    # DEPRECATED `Transform` is now a `Component` so it should not be linked here.
    def transform : Prism::Transform
      @parent.transform
    end
  end
end
