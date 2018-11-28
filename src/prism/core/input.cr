require "crystglfw"
require "./vector2f"

module Prism
  # Manages user input to the engine

  class Input
    NUM_KEYCODES     = 1024
    NUM_MOUSEBUTTONS =   15

    KEY_ESCAPE     =   27
    KEY_F1         =    1
    KEY_F2         =    1
    KEY_F3         =    2
    KEY_F4         =    3
    KEY_F5         =    4
    KEY_F6         =    5
    KEY_F7         =    6
    KEY_F8         =    7
    KEY_F9         =    8
    KEY_F10        =    9
    KEY_F11        =   11
    KEY_F12        =   12
    KEY_LEFT       = 1100
    KEY_UP         = 1101
    KEY_RIGHT      = 1102
    KEY_DOWN       = 1103
    KEY_PAGE_UP    =  104
    KEY_PAGE_DOWN  =  105
    KEY_HOME       =  106
    KEY_END        =  107
    KEY_INSERT     =  108
    KEY_NUM_LOCK   =  109
    KEY_BACK_SLASH =   47
    KEY_ASTERISK   =   42
    KEY_MINUS      =   45
    KEY_PLUS       =   43
    KEY_RETURN     =   13
    KEY_SHIFT      =  112
    KEY_LEFT_CTRL  =  114
    KEY_RIGHT_CTRL =  115
    KEY_E          =  101
    KEY_W          =  119
    KEY_S          =  115
    KEY_A          =   97
    KEY_D          =  100

    alias Key = CrystGLFW::Key
    alias MouseButton = CrystGLFW::MouseButton

    @last_keys = StaticArray(Bool, NUM_KEYCODES).new(false)
    @last_mouse = StaticArray(Bool, NUM_MOUSEBUTTONS).new(false)
    
    def initialize(@window : CrystGLFW::Window)
    end

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
