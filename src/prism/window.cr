require "lib_glut"

module Prism
  class Window

    def self.create_window(width : Int32, height : Int32, title : String, render : Void -> Void)
      args = [] of String
      argv = args.map(&.to_unsafe).to_unsafe
      size = args.size
      LibGlut.init(pointerof(size), argv)
      LibGlut.init_display_mode(LibGlut::SINGLE)
      LibGlut.init_window_size(width, height)
      LibGlut.init_window_position(100, 100)
      LibGlut.create_window(title)

      LibGlut.display_func(render)
      
      LibGlut.main_loop()
    end

    def self.isCloseRequested : Boolean

    end

    def self.getWidth : Int32
      return LibGlut.get(LibGlut::WINDOW_WIDTH)
    end

    def self.getHeight : Int32
      return LibGlut.get(LibGlut::WINDOW_HEIGHT)
    end

  end
end
