require "crash"

module Prism
  # TODO: this needs a better name. It confuses with the actual texture.
  #  Maybe just GUIComponent.
  class GUITexture < Crash::Component
    @position : Vector2f
    @scale : Vector2f
    @texture : Prism::Texture

    getter position, scale, texture

    # When setting the *position* remember that 0,0 is at the center of the screen.
    # So the screen top left corner is -1, 1 while the bottom right corner is 1, -1
    # The *position* represents the center of the GUI texture.
    # The *scale* represents the size of the GUI texture relative to the screen.
    # However, that's not working.
    def initialize(@texture, @position, @scale)
    end
  end
end
