require "lib_gl"
require "./lib_glut"

# A game engine written in Crystal
module Prism
  VERSION = "0.1.0"

  # TODO: we must build this.
  class Window
  end

  def start
    drawTriangle = ->( x : Void) {
      # LibGL.color3f(1.0, 1.0, 1.0);
      LibGL.ortho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0);

      LibGL.begin(LibGL::TRIANGLES);
      LibGL.vertex3f(-0.7, 0.7, 0);
      LibGL.vertex3f(0.7, 0.7, 0);
      LibGL.vertex3f(0, -1, 0);
      LibGL.end();

      LibGL.flush();
    }

    argv = ARGV.map(&.to_unsafe).to_unsafe
    size = ARGV.size
    LibGlut.init(pointerof(size), argv)
    LibGlut.init_display_mode(LibGlut::SINGLE)
    LibGlut.init_window_size(500, 500)
    LibGlut.init_window_position(100, 100)
    LibGlut.create_window("OpenGL - Creating a triangle")

    LibGlut.display_func(drawTriangle)

    LibGlut.main_loop()
  end
end
