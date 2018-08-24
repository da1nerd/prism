require "lib_glut"
require "../lib_gluc"

module CrystGLUT

  class Window
    NUM_KEYCODES = 256
    @display_box : Pointer(Void)?
    @close_box : Pointer(Void)?
    @keyboard_box: Pointer(Void)?
    @mouse_box: Pointer(Void)?

    @close_requested = false
    @is_open = false
    @key_down = [] of UInt8
    @mouse_down = [] of Int32

    def initialize(width : Int32, height : Int32, title : String)
      args = [] of String
      argv = args.map(&.to_unsafe).to_unsafe
      size = args.size
      LibGlut.init(pointerof(size), argv)
      LibGlut.init_display_mode(LibGlut::SINGLE)
      LibGlut.init_window_size(width, height)
      LibGlut.init_window_position(100, 100)
      LibGlut.set_option(LibGlut::ACTION_ON_WINDOW_CLOSE, LibGlut::ACTION_CONTINUE_EXECUTION)
      @title = title
      @id = LibGlut.create_window(title)
    end

    # Assigns a block to receive the window close event.
    private def on_close(&block : ->)
      boxed_data = Box.box(block)
      @close_box = boxed_data

      LibGluc.close_func(->(data : Void*) {
        data_as_callback = Box(typeof(block)).unbox(data)
        data_as_callback.call()
      }, boxed_data)
    end

    # Assigns a block to receive keyboard events.
    # The block will receive the character code along with the mouse's current x,y coordinates.
    private def on_keyboard(&block : UInt8, Int32, Int32 ->)
      boxed_data = Box.box(block)
      @keyboard_box = boxed_data

      LibGluc.keyboard_func(->(data : Void*, char : UInt8, x : Int32, y : Int32) {
        data_as_callback = Box(typeof(block)).unbox(data)
        data_as_callback.call(char, x, y)
      }, boxed_data)
    end

    # Assigns a block to receive mouse button events.
    # The block will receive the button number, button, state, and x,y coordinates.
    private def on_mouse(&block : Int32, Int32, Int32, Int32 ->)
      boxed_data = Box.box(block)
      @mouse_box = boxed_data

      LibGluc.mouse_func(->(data : Void*, button : Int32, state : Int32, x : Int32, y : Int32) {
        data_as_callback = Box(typeof(block)).unbox(data)
        data_as_callback.call(button, state, x, y)
      }, boxed_data)
    end

    # Assigns a block to recieve active mouse motion events.
    # These events occur when a mouse button is pressed.
    # The block will receive the x,y coordinates of the mouse.
    #
    # NOTE: This method must be called before `Window.on_render`
    def on_motion(&block : Int32, Int32 ->)
      LibGlut.motion_func(block)
    end

    # Assigns a block to receive passive mouse motion events.
    # These events occur when no mouse buttons are pressed.
    # The block will receive the x,y coordinates of the mouse.
    #
    # NOTE: This method must be called before `Window.on_render`
    def on_passive_motion(&block : Int32, Int32 ->)
      LibGlut.passive_motion_func(block)
    end

    # Assigns a block to manage rendering the display
    def on_display(&block : ->)
      # TODO: this is how we would execute dispaly_func if it supported data : Void*
      boxed_data = Box.box(block)
      @display_box = boxed_data

      LibGluc.display_func(->(data : Void*) {
        data_as_callback = Box(typeof(block)).unbox(data)
        data_as_callback.call()
      }, boxed_data)
    end

    # Process queued OpenGL commands
    def render
      LibGlut.main_loop_event()
    end

    # Terminates the window
    def dispose
      LibGlut.leave_main_loop()
      LibGluc.display_func(nil, nil)
      LibGluc.keyboard_func(nil, nil)
      LibGluc.mouse_func(nil, nil)
      LibGluc.motion_func(nil, nil)
      LibGluc.passive_motion_func(nil, nil)
      LibGluc.close_func(nil, nil)
    end

    # Opens the window
    def open
      if @is_open
        return
      end

      # TODO: use this in our main component and manage close request state there.
      on_close do
        @close_requested = true
      end

      proxy_input

      @is_open = true
      # TRICKY: render once to allow Freeglut to process events and open the window
      render
    end

    # Caches input state change so it can be queried deterministically
    private def proxy_input

      on_keyboard do |char, x, y|
        if !contains(@key_down, char)
          @key_down.push(char)
        else
          @key_down.delete(char)
        end
      end

      on_mouse do |button, state, x, y|
        if state == 1
          if !contains(@mouse_down, button)
            @mouse_down.push(button)
          end
        else
          if contains(@mouse_down, button)
            @mouse_down.delete(button)
          end
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

    def is_key_down(key_code : Int32) : Boolean
        return contains(@key_down, key_code)
    end

    def is_key_up(key_code : Int32) : Boolean
        return !contains(@key_down, key_code)
    end

    # checks if the mouse key is down
    def getMouseDown(key_code : Int32) : Boolean
      return contains(@mouse_down, key_code)
    end

    def getMouseUp(key_code : Int32) : Boolean

    end

    # Returns the width of the window
    def get_width : Int32
      return LibGlut.get(LibGlut::WINDOW_WIDTH)
    end

    # Returns the height of the window
    def get_height : Int32
      return LibGlut.get(LibGlut::WINDOW_HEIGHT)
    end
#GLUT_ACTION_ON_WINDOW_CLOSE
    def is_close_requested : Bool
      @close_requested
    end
  end
end
