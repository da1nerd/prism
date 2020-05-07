require "crash"

module Prism
  # An entity is a collection of components
  # All entities start with a default `Transform` and `Material`
  class Entity < Crash::Entity
    def initialize
      super()
      add Transform.new
      add Material.new
    end

    # Force all camera controls under the same class type
    # So the rendering system can find them.
    def add(camera_controls : Prism::CameraControls::Controller)
      add camera_controls, Prism::CameraControls::Controller
    end
  end
end
