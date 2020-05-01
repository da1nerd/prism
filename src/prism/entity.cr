require "crash"

module Prism
  # An entity is a collection of components
  # All entities start with a default `Transform`.
  class Entity < Crash::Entity
    def initialize
      super()
      add Transform.new
    end

    # Force all camera controls under the same class type
    # So the rendering system can find them.
    def add(camera_controls : Prism::CameraControls)
      add camera_controls, Prism::CameraControls
    end
  end
end
