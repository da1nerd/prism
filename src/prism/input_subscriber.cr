module Prism
  # Dispatches input events to the rest of the components in an `Entity`
  class InputSubscriber < Crash::Component
    # Dispatches input events to the rest of the components on the *entity*
    # This may modify the *entity* directly
    def input!(tick : RenderLoop::Tick, input : RenderLoop::Input, entity : Crash::Entity)
      entity.get_all.each do |component|
        if component.is_a?(InputReceiver)
          component.input!(tick, input, entity)
        end
      end
    end
  end
end
