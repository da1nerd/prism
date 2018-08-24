require "../crystglut"

module Prism

  class Input
    NUM_KEYCODES = 256;

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
    KEY_LEFT = 100
    KEY_UP = 101
    KEY_RIGHT = 102
    KEY_DOWN = 103
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

    @current_keys = [] of UInt8 | Int32;
    @down_keys = [] of UInt8 | Int32;
    @up_keys = [] of UInt8 | Int32;

    def initialize(@window : CrystGLUT::Window)

    end

    def update

      # track keys released this frame
      @up_keys.clear

      0.upto(NUM_KEYCODES) do |i|
        if !get_key(i) && contains(@current_keys, i)
          @up_keys.push(i)
        end
      end

      # track keys pressed this frame
      @down_keys.clear

      0.upto(NUM_KEYCODES) do |i|
        if get_key(i) && !contains(@current_keys, i)
          @down_keys.push(i)
        end
      end

      # track keys pressed last frame
      @current_keys.clear

      0.upto(NUM_KEYCODES) do |i|
        if get_key(i)
          @current_keys.push(i)
        end
      end

    end

    # checks if an array contains an element
    protected def contains(array : Array(UInt8 | Int32), element : UInt8 | Int32)
      val = array.find { |i| i == element }
      if val && val >= 0
        return true
      end
      return false
    end

    # Checks if the key is currently down
    def get_key(key_code : UInt8 | Int32) : Bool
      return @window.is_key_down(key_code)
    end

    # Checks if the key was pressed in this frame
    def get_key_down(key_code : UInt8 | Int32) : Bool
      return contains(@down_keys, key_code)
    end

    # Checks if the key was released in this frame
    def get_key_up(key_code : UInt8 | Int32) : Bool
      return contains(@up_keys, key_code)
    end

  end

end
