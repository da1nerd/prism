require "lib_glut"

module Prism
  class Window

    def initialize(
        width : Int32,
        height : Int32,
        title : String,
        render : Proc(Void, Nil),
        keyboard : Proc(UInt8, Int32, Int32, Nil),
        mouse : Proc(Int32, Int32, Int32, Int32, Nil)
      )
      args = [] of String
      argv = args.map(&.to_unsafe).to_unsafe
      size = args.size
      LibGlut.init(pointerof(size), argv)
      LibGlut.init_display_mode(LibGlut::SINGLE)
      LibGlut.init_window_size(width, height)
      LibGlut.init_window_position(100, 100)
      @title = title
      @id = LibGlut.create_window(title)

      LibGlut.display_func(render)
      LibGlut.keyboard_func(keyboard)
      LibGlut.mouse_func(mouse)

      LibGlut.main_loop()
    end

    def on_keyboard
      # TODO: impliment this so we don't have to pass in the keyboard handler to the constructor
    end

    def on_mouse
      # TODO: implement this
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
