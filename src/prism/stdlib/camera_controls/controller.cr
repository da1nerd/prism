module Prism::CameraControls
  # A special component type for controlling the camera.
  abstract class Controller < Crash::Component
    @camera_transform : Prism::Transform = Prism::Transform.new
    getter camera_transform
  end
end
