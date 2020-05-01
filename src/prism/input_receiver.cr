module Prism
  module InputReceiver
    # Receives input events from the `InputDispatcher`
    abstract def input!(tick : RenderLoop::Tick, input : RenderLoop::Input, entity : Crash::Entity)
  end
end
