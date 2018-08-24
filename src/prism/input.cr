require "../crystglut"

module Prism

  class Input
    NUM_KEYCODES = 256;

    @current_keys = [] of UInt8;
    @down_keys = [] of UInt8;
    @up_keys = [] of UInt8;

    def initalize(@window : CrystGLUT::Window)

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
    def get_key(key_code : UInt8) : Bool
      return @window.is_key_down(key_code)
    end

    # Checks if the key was pressed in this frame
    def get_key_down(key_code : UInt8) : Bool
      return contains(@down_keys, key_code)
    end

    # Checks if the key was released in this frame
    def get_key_down(key_code : UInt8) : Bool
      return contains(@up_keys, key_code)
    end

  end

end
