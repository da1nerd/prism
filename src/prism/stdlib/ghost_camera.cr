module Prism
  # A camera has free movement using the mouse and arrow keys
  # Simply adding this camera to your scene will give you the ablity
  # to fly around and view your scene from different angles.
  class GhostCamera < Prism::Entity
    def initialize
      super
      add_component(Prism::Camera.new)
      add_component(Prism::FreeLook.new)
      add_component(Prism::FreeMove.new)
    end
  end
end
