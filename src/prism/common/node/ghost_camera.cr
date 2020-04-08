module Prism::Common::Node
  # A camera has free movement using the mouse and arrow keys
  class GhostCamera < Core::GameObject
    def initialize
      super
      add_component(Core::Camera.new)
      add_component(Component::FreeLook.new)
      add_component(Component::FreeMove.new)
    end
  end
end
