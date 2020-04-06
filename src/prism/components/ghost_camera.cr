require "../game_object"

module Prism
  # A camera has free movement using the mouse and arrow keys
  class GhostCamera < GameObject
    def initialize
      super
      add_component(Camera.new)
      add_component(FreeLook.new)
      add_component(FreeMove.new)
    end
  end
end
