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
    end

    # delegates the keyboard handler
    def on_keyboard(&block : UInt8, Int32, Int32 ->)
      # @on_keyboard_callback = block
      LibGlut.keyboard_func(block)
    end

    # delegates the mouse handler
    def on_mouse(&block : Int32, Int32, Int32, Int32 ->)
      # @on_mouse_callback = block
      LibGlut.mouse_func(block)
    end

    # delegates the render handler
    def on_render(&block : Void ->)
      # @on_render_callback = block
      LibGlut.display_func(block)
      LibGlut.main_loop()
    end

    def isCloseRequested : Boolean

    end

    def getWidth : Int32
      return LibGlut.get(LibGlut::WINDOW_WIDTH)
    end

    def getHeight : Int32
      return LibGlut.get(LibGlut::WINDOW_HEIGHT)
    end

  end
end
