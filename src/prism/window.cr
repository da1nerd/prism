require "lib_glut"

module Prism

  class Window
    @@box : Pointer(Void)?

    def self.wrapped_display_func(callback : Void* -> Void, data : Void*) : Void
      # TODO: send proc then execute callback with data.
      # callback.call(data)
      proc = -> (c : (Void* -> Void), d : Void*) {
        c.call(d)
      }
      # proc = -> (x : Void) {
      #   callback.call(data)
      # }
      filled_proc = proc.partial(callback)
      ready_proc = filled_proc.partial(data)
      # ready_proc.call()
      LibGlut.display_func(ready_proc);
    end

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

      LibGlut.close_func ->(x) { puts "closed" }
    end

    # Assigns a block to receive keyboard events.
    # The block will receive the character code along with the mouse's current x,y coordinates.
    #
    # NOTE: This method must be called before `Window.on_render`
    def on_keyboard(&block : UInt8, Int32, Int32 ->)
      LibGlut.keyboard_func(block)
    end

    # Assigns a block to receive mouse button events.
    # The block will receive the button number, button, state, and x,y coordinates.
    #
    # NOTE: This method must be called before `Window.on_render`
    def on_mouse(&block : Int32, Int32, Int32, Int32 ->)
      LibGlut.mouse_func(block)
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
      boxed_data = Box.box(block)
      @@box = boxed_data

      Window.wrapped_display_func(->(data : Void*) {
        data_as_callback = Box(typeof(block)).unbox(data)
        data_as_callback.call()
      }, boxed_data)
    end

    # Process one iteration's worth of events
    def render
      LibGlut.main_loop_event()
    end

    # Terminates the window
    def destroy
      LibGlut.leave_main_loop()
    end

    def open
      # LibGlut.main_loop
    end

    # Returns the width of the window
    def getWidth : Int32
      return LibGlut.get(LibGlut::WINDOW_WIDTH)
    end

    # Returns the height of the window
    def getHeight : Int32
      return LibGlut.get(LibGlut::WINDOW_HEIGHT)
    end
#GLUT_ACTION_ON_WINDOW_CLOSE
    def is_close_requested : Bool
      false
    end
  end
end
