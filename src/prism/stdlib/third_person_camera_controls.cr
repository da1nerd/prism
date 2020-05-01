require "crash"

module Prism
  # TODO: can't we come up with a better name? Or just put it in a namespace.
  # CameraControls::ThirdPerson
  # We may want to put this in the core as well.
  #
  # This provides third person view and controls to the camera.
  # The `Camera` will be positioned view it's attached `Entity` from the third person.
  class ThirdPersonCameraControls < Crash::Component
    include Prism::InputReceiver

    def input!(tick : RenderLoop::Tick, input : RenderLoop::Input, entity : Crash::Entity)
      # TODO: implement third person view and controls
    end
  end
end
