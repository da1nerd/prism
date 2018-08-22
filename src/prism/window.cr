require "lib_glut"

module Prism
  class Window
    def initialize(width : Int32, height : Int32, title : String)
      args = [] of String
      argv = args.map(&.to_unsafe).to_unsafe
      size = args.size
      LibGlut.init(pointerof(size), argv)
      LibGlut.init_display_mode(LibGlut::SINGLE)
      LibGlut.init_window_size(width, height)
      LibGlut.init_window_position(100, 100)
      @title = title
      @id = LibGlut.create_window(title)
      @is_running = false
    end

    # Assigns a block to receive keyboard events
    #
    # NOTE: This method must be called before `Window.on_render`
    def on_keyboard(&block : UInt8, Int32, Int32 ->)
      LibGlut.keyboard_func(block)
    end

    # Assigns a block to receive mouse button events
    #
    # NOTE: This method must be called before `Window.on_render`
    def on_mouse(&block : Int32, Int32, Int32, Int32 ->)
      LibGlut.mouse_func(block)
    end

    # Assigns a block to recieve mouse motion events
    #
    # NOTE: This method must be called before `Window.on_render`
    def on_motion(&block : Int32, Int32 ->)
      LibGlut.motion_func(block)
    end

    # Assigns a block to receive passive mouse motion events
    #
    # NOTE: This method must be called before `Window.on_render`
    def on_passive_motion(&block : Int32, Int32 ->)
      LibGlut.passive_motion_func(block)
    end

    # Assigns a block to manage the rendering
    def on_render(&block : Void ->)
      @is_running = true
      LibGlut.display_func(block)
      LibGlut.main_loop
    end

    # Returns the width of the window
    def getWidth : Int32
      return LibGlut.get(LibGlut::WINDOW_WIDTH)
    end

    # Returns the height of the window
    def getHeight : Int32
      return LibGlut.get(LibGlut::WINDOW_HEIGHT)
    end
  end
end
