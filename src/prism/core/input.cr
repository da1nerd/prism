require "crystglfw"
require "./vector2f"

module Prism

  # Provides an abstraction over window input so that the engine can easily read input state
  class Input
    NUM_KEYCODES     = 1024
    NUM_MOUSEBUTTONS =   15

    # Keys enum.
    # This is an alias of [CrystalGLFW::Key](https://calebuharrison.gitbooks.io/crystglfw-guide/content/deep-dive/keys.html)
    alias Key = CrystGLFW::Key

    # Mouse buttons enum.
    # This is an alias of [CrystalGLFW::Key](https://calebuharrison.gitbooks.io/crystglfw-guide/content/deep-dive/mouse-buttons.html)
    alias MouseButton = CrystGLFW::MouseButton

    @last_keys = StaticArray(Bool, NUM_KEYCODES).new(false)
    @last_mouse = StaticArray(Bool, NUM_MOUSEBUTTONS).new(false)
    
    def initialize(@window : CrystGLFW::Window)
    end

    # Processes the window input during each update tick
    def update
      # TODO: this code is ugly and should probably be simplified

      0.upto(NUM_KEYCODES - 1) do |i|
        key = Input::Key.from_value?(i)
        if k = key
          @last_keys[i] = get_key(k)
        else
          @last_keys[i] = false
        end
      end

      0.upto(NUM_MOUSEBUTTONS - 1) do |i|
        mouse = Input::MouseButton.from_value?(i)
        if m = mouse
          @last_mouse[i] = get_mouse(m)
        else
          @last_mouse[i] = false
        end
      end
    end

    # Checks if the key is currently down
    def get_key(key_code : Key) : Bool
      return @window.key_pressed?(key_code)
    end

    # Checks if the key was pressed in this frame
    def get_key_pressed(key_code : Key) : Bool
      return get_key(key_code) && !@last_keys[key_code.value]
    end

    # Returns an array of keys that are currently pressed
    # def get_keys : Array(Key)
    #   keys = [] of Key
    #   @window.get_keys_down.each do |key|
    #     if get_key_pressed(key)
    #       keys.push(key)
    #     end
    #   end
    #   return keys
    # end

    # Checks if the key was released in this frame
    def get_key_released(key_code : Key) : Bool
      return !get_key(key_code) && @last_keys[key_code.value]
    end

    # Check if the mouse button is currently down
    def get_mouse(mouse_button : MouseButton) : Bool
      return @window.mouse_button_pressed?(mouse_button)
    end

    # Checks if the mouse button was pressed in this frame
    def get_mouse_pressed(mouse_button : MouseButton) : Bool
      return get_mouse(mouse_button) && !@last_mouse[mouse_button.value]
    end

    # Checks if the mouse button was released in this frame
    def get_mouse_released(mouse_button : MouseButton) : Bool
      return !get_mouse(mouse_button) && @last_mouse[mouse_button.value]
    end

    # Returns the position of the mouse
    def get_mouse_position : Vector2f
      cursor = @window.cursor
      return Vector2f.new(cursor.position[:x].to_f32, cursor.position[:y].to_f32)
    end

    # Sets the mouse position within the window
    def set_mouse_position(position : Vector2f)
      @window.cursor.set_position(position.x, position.y)
    end

    # Controls the cursor visibility within the window
    def set_cursor(enabled : Bool)
      if enabled
        @window.cursor.normalize
      else
        @window.cursor.hide
      end
    end

    # Returns the center of the window
    def get_center : Vector2f
      size = @window.size
      return Vector2f.new(size[:width].to_f32 / 2.0f32, size[:height].to_f32 / 2.0f32)
    end
  end
end
