require "../src/prism"
require "lib_gl"

#  Example creating a window
module Example
  extend self


  render = ->( x : Void) {
    LibGL.clear(LibGL::COLOR_BUFFER_BIT | LibGL::DEPTH_BUFFER_BIT)

    LibGL.begin(LibGL::TRIANGLES);
    LibGL.color3f(1, 0, 0);
    LibGL.vertex2f(-0.5, -0.5);
    LibGL.color3f(0, 1, 0);
    LibGL.vertex2f(0.5, -0.5);
    LibGL.color3f(0, 0, 1);
    LibGL.vertex2f(0, 0.5);

    LibGL.end();
    puts "hello world"
    LibGL.flush();
  }

  keyboard = ->(c : UInt8, x : Int32, y : Int32) {
    if c == 27
      exit()
    end
  }

  mouse = ->(button : Int32, state : Int32, x : Int32, y : Int32) {

  }

  # TODO: only create a blank window
  window = Prism::Window.new(800, 600, "Sample Window", render, keyboard, mouse)

end
