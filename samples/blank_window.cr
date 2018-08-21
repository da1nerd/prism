require "../src/prism"
require "lib_gl"

#  Example creating a window
module Example
  extend self


  render = ->( x : Void) {
    # LibGL.color3f(1.0, 1.0, 1.0);
    LibGL.ortho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0);

    LibGL.begin(LibGL::TRIANGLES);
    LibGL.vertex3f(-0.7, 0.7, 0);
    LibGL.vertex3f(0.7, 0.7, 0);
    LibGL.vertex3f(0, -1, 0);
    LibGL.end();
    puts "hello world"
    LibGL.flush();
  }

  # TODO: only create a blank window
  Prism::Window.create_window(800, 600, "Sample Window", render)

end
