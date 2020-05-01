module Prism
    abstract class CameraControls < Crash::Component
        @camera_transform : Prism::Transform = Prism::Transform.new
        getter camera_transform
    end
end