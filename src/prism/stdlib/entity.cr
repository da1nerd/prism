require "crash"

module Prism
  # A default entity with some standard components baked in.
  class Entity < Crash::Entity
    def initialize
      super()
      # possess a position and rotation
      add Prism::Transform.new
      # subscribe to input events
      add Prism::InputSubscriber.new
      # legacy material information
      add Material.new
    end

    # Shortcut to retrieve the `Material` component.
    def material : Prism::Material
      get(Prism::Material).as(Prism::Material)
    end

    # Shortcut to retrieve the `Transform` component.
    def transform : Prism::Transform
      get(Prism::Transform).as(Prism::Transform)
    end

    # Force all camera controls under the same class type
    # So the rendering system can find them.
    def add(camera_controls : Prism::CameraControls::Controller)
      add camera_controls, Prism::CameraControls::Controller
    end
  end
end
