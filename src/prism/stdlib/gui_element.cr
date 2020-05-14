require "crash"

module Prism
  # Represents a single GUI element.
  # GUIElements are 2d graphics drawn on the screen with a z-axis equal to 0.
  class GUIElement < Crash::Component
    @position : Vector2f
    @scale : Vector2f
    @texture : Prism::Texture2D

    getter position, scale, texture

    # When setting the *position* remember that 0,0 is at the center of the screen.
    # So the screen top left corner is -1, 1 while the bottom right corner is 1, -1
    # The *position* represents the center of the GUI texture.
    # The *scale* represents the size of the GUI texture relative to the screen.
    def initialize(@texture, @position, @scale)
    end
  end
end
