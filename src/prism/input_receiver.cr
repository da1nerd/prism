require "render_loop"
require "crash"

module Prism
  module InputReceiver
    # Receives input events from the `InputSubscriber`
    abstract def input!(tick : RenderLoop::Tick, input : RenderLoop::Input, entity : Crash::Entity)
  end
end
