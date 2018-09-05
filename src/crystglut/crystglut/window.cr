require "lib_glut"

module CrystGLUT

  class Window
    NUM_KEYCODES = 256

    @display_box : Pointer(Void)?
    @close_box : Pointer(Void)?
    @keyboard_box: Pointer(Void)?
    @keyboard_up_box: Pointer(Void)?
    @special_keyboard_box: Pointer(Void)?
    @special_keyboard_up_box: Pointer(Void)?
    @mouse_box: Pointer(Void)?
    @motion_box: Pointer(Void)?
    @passive_motion_box: Pointer(Void)?

    @close_requested = false
    @is_open = false
    @key_down = [] of UInt8 | Int32
    @mouse_down = [] of Int32
    @mouse_x : Float32 = 0.0
    @mouse_y : Float32 = 0.0

    def initialize(width : Int32, height : Int32, title : String)
      args = [] of String
      argv = args.map(&.to_unsafe).to_unsafe
      size = args.size
      LibGLUT.init(pointerof(size), argv)
      LibGLUT.init_display_mode(LibGLUT::SINGLE)
      LibGLUT.init_window_size(width, height)
      LibGLUT.init_window_position(100, 100)
      LibGLUT.set_option(LibGLUT::ACTION_ON_WINDOW_CLOSE, LibGLUT::ACTION_CONTINUE_EXECUTION)
      @title = title
      @id = LibGLUT.create_window(title)
    end

    # Assigns a block to receive the window close event.
    private def on_close(&block : ->)
      boxed_data = Box.box(block)
      @close_box = boxed_data

      LibGLUT.close_func_x(->(data : Void*) {
        data_as_callback = Box(typeof(block)).unbox(data)
        data_as_callback.call()
      }, boxed_data)
    end

    # Assigns a block to receive keyboard down events.
    # The block will receive the character code along with the mouse's current x,y coordinates.
    private def on_keyboard(&block : UInt8, Int32, Int32 ->)
      boxed_data = Box.box(block)
      @keyboard_box = boxed_data

      LibGLUT.keyboard_func_x(->(data : Void*, char : UInt8, x : Int32, y : Int32) {
        data_as_callback = Box(typeof(block)).unbox(data)
        data_as_callback.call(char, x, y)
      }, boxed_data)
    end

    # Assigns a block to receive keyboard up events.
    # The block will receive the character code along with the mouse's current x,y coordinates.
    private def on_keyboard_up(&block : UInt8, Int32, Int32 ->)
      boxed_data = Box.box(block)
      @keyboard_up_box = boxed_data

      LibGLUT.keyboard_up_func_x(->(data : Void*, char : UInt8, x : Int32, y : Int32) {
        data_as_callback = Box(typeof(block)).unbox(data)
        data_as_callback.call(char, x, y)
      }, boxed_data)
    end

    # Assigns a block to receive special keyboard down events.
    # The block will receive the character code along with the mouse's current x,y coordinates.
    private def on_special_keyboard(&block : Int32, Int32, Int32 ->)
      boxed_data = Box.box(block)
      @special_keyboard_box = boxed_data

      LibGLUT.special_func_x(->(data : Void*, key : Int32, x : Int32, y : Int32) {
        data_as_callback = Box(typeof(block)).unbox(data)
        data_as_callback.call(key, x, y)
      }, boxed_data)
    end

    # Assigns a block to receive special keyboard up events.
    # The block will receive the character code along with the mouse's current x,y coordinates.
    private def on_special_keyboard_up(&block : Int32, Int32, Int32 ->)
      boxed_data = Box.box(block)
      @special_keyboard_up_box = boxed_data

      LibGLUT.special_up_func_x(->(data : Void*, key : Int32, x : Int32, y : Int32) {
        data_as_callback = Box(typeof(block)).unbox(data)
        data_as_callback.call(key, x, y)
      }, boxed_data)
    end

    # Assigns a block to receive mouse button events.
    # The block will receive the button number, button, state, and x,y coordinates.
    private def on_mouse(&block : Int32, Int32, Int32, Int32 ->)
      boxed_data = Box.box(block)
      @mouse_box = boxed_data

      LibGLUT.mouse_func_x(->(data : Void*, button : Int32, state : Int32, x : Int32, y : Int32) {
        data_as_callback = Box(typeof(block)).unbox(data)
        data_as_callback.call(button, state, x, y)
      }, boxed_data)
    end

    # Assigns a block to receive mouse motion events.
    private def on_motion(&block : Int32, Int32 ->)
      boxed_data = Box.box(block)
      @motion_box = boxed_data

      LibGLUT.motion_func_x(->(data : Void*, x : Int32, y : Int32) {
        data_as_callback = Box(typeof(block)).unbox(data)
        data_as_callback.call(x, y)
      }, boxed_data)
    end

    # Assigns a block to receive passive mouse motion events.
    private def on_passive_motion(&block : Int32, Int32 ->)
      boxed_data = Box.box(block)
      @passive_motion_box = boxed_data

      LibGLUT.passive_motion_func_x(->(data : Void*, x : Int32, y : Int32) {
        data_as_callback = Box(typeof(block)).unbox(data)
        data_as_callback.call(x, y)
      }, boxed_data)
    end

    # Assigns a block to manage rendering the display
    def on_display(&block : ->)
      # TODO: this is how we would execute dispaly_func if it supported data : Void*
      boxed_data = Box.box(block)
      @display_box = boxed_data

      LibGLUT.display_func_x(->(data : Void*) {
        data_as_callback = Box(typeof(block)).unbox(data)
        data_as_callback.call()
      }, boxed_data)
    end

    # Process queued OpenGL commands
    def render
      LibGLUT.main_loop_event()
    end

    # Terminates the window
    def dispose
      LibGLUT.leave_main_loop()
      LibGLUT.display_func_x(nil, nil)
      LibGLUT.keyboard_func_x(nil, nil)
      LibGLUT.keyboard_up_func_x(nil, nil)
      LibGLUT.special_func_x(nil, nil)
      LibGLUT.special_up_func_x(nil, nil)
      LibGLUT.mouse_func_x(nil, nil)
      LibGLUT.motion_func_x(nil, nil)
      LibGLUT.passive_motion_func_x(nil, nil)
      LibGLUT.close_func_x(nil, nil)
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

      on_motion do |x, y|
        @mouse_x = x * 1.0f32
        @mouse_y = y * 1.0f32
      end

      on_passive_motion do |x, y|
        @mouse_x = x * 1.0f32
        @mouse_y = y * 1.0f32
      end

      on_keyboard do |char, x, y|
        if !contains(@key_down, char)
          @key_down.push(char)
        end
      end

      on_keyboard_up do |char, x, y|
        if contains(@key_down, char)
          @key_down.delete(char)
        end
      end

      on_special_keyboard do |key, x, y|
        if !contains(@key_down, key)
          @key_down.push(key)
        end
      end

      on_special_keyboard_up do |key, x, y|
        if contains(@key_down, key)
          @key_down.delete(key)
        end
      end

      on_mouse do |button, state, x, y|
        if state == 0
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

    # checks if the key is down
    def is_key_down(key_code : Int32) : Bool
        return contains(@key_down, key_code)
    end

    # checks if the mouse key is down
    def is_mouse_down(key_code : Int32) : Bool
      return contains(@mouse_down, key_code)
    end

    # returns the x coordinate of the mouse
    def get_mouse_x : Float32
      return @mouse_x
    end

    # Returns the y coordinate of the mouse
    def get_mouse_y : Float32
      return @mouse_y
    end

    # Returns the width of the window
    def get_width : Int32
      return LibGLUT.get(LibGLUT::WINDOW_WIDTH)
    end

    # Returns the height of the window
    def get_height : Int32
      return LibGLUT.get(LibGLUT::WINDOW_HEIGHT)
    end
#GLUT_ACTION_ON_WINDOW_CLOSE
    def is_close_requested : Bool
      @close_requested
    end
  end
end
