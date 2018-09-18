require "cryst_glut"
require "./vector2f"

module Prism

  class Input
    NUM_KEYCODES = 1256
    NUM_MOUSEBUTTONS = 10

    KEY_ESCAPE = 27
    KEY_F1 = 1
    KEY_F2 = 1
    KEY_F3 = 2
    KEY_F4 = 3
    KEY_F5 = 4
    KEY_F6 = 5
    KEY_F7 = 6
    KEY_F8 = 7
    KEY_F9 = 8
    KEY_F10 = 9
    KEY_F11 = 11
    KEY_F12 = 12
    KEY_LEFT = 1100
    KEY_UP = 1101
    KEY_RIGHT = 1102
    KEY_DOWN = 1103
    KEY_PAGE_UP = 104
    KEY_PAGE_DOWN = 105
    KEY_HOME = 106
    KEY_END = 107
    KEY_INSERT = 108
    KEY_NUM_LOCK = 109
    KEY_BACK_SLASH = 47
    KEY_ASTERISK = 42
    KEY_MINUS = 45
    KEY_PLUS = 43
    KEY_RETURN = 13
    KEY_SHIFT = 112
    KEY_LEFT_CTRL = 114
    KEY_RIGHT_CTRL = 115
    KEY_W = 119
    KEY_S = 115
    KEY_A = 97
    KEY_D = 100

    @last_keys = StaticArray(Bool, NUM_KEYCODES).new(false)
    @last_mouse = StaticArray(Bool, NUM_MOUSEBUTTONS).new(false)

    def initialize(@window : CrystGLUT::Window)
    end

    def update

      0.upto(NUM_KEYCODES - 1) do |i|
        @last_keys[i] = get_key(i)
      end

      0.upto(NUM_MOUSEBUTTONS - 1) do |i|
        @last_mouse[i] = get_mouse(i)
      end

    end

    # Checks if the key is currently down
    def get_key(key_code : UInt8 | Int32) : Bool
      return @window.is_key_down(key_code)
    end

    # Checks if the key was pressed in this frame
    def get_key_down(key_code : UInt8 | Int32) : Bool
      return get_key(key_code) && !@last_keys[key_code]
    end

    # Returns an array of keys that are current pressed
    def get_any_key_down : Array(Int32 | UInt8)
      keys = [] of (Int32 | UInt8)
      @window.get_keys_down.each do |key|
        if get_key_down(key)
          keys.push(key)
        end
      end
      return keys
    end

    # Checks if the key was released in this frame
    def get_key_up(key_code : UInt8 | Int32) : Bool
      return !get_key(key_code) && @last_keys[key_code]
    end

    # Check if the mouse button is currently down
    def get_mouse(mouse_button : Int32) : Bool
      return @window.is_mouse_down(mouse_button)
    end

    # Checks if the mouse button was pressed in this frame
    def get_mouse_down(mouse_button : Int32) : Bool
      return get_mouse(mouse_button) && !@last_mouse[mouse_button]
    end

    # Checks if the mouse button was released in this frame
    def get_mouse_up(mouse_button : Int32) : Bool
      return !get_mouse(mouse_button) && @last_mouse[mouse_button]
    end

    # Returns the position of the mouse
    def get_mouse_position : Vector2f
      return Vector2f.new(@window.get_mouse_x, @window.get_mouse_y)
    end

    # Sets the mouse position within the window
    def set_mouse_position (position : Vector2f)
      @window.set_mouse_position(position.x, position.y)
    end

    # Controls the cursor visibility within the window
    def set_cursor(enabled : Bool)
      @window.enable_cursor(enabled)
    end

    # Returns the center of the window
    def get_center : Vector2f
      return Vector2f.new(@window.get_width / 2.0f32, @window.get_height / 2.0f32)
    end
  end

end
