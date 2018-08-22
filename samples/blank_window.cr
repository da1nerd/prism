require "../src/prism"
require "lib_gl"

#  Example creating a window
module Example
  extend self

  window = Prism::Window.new(800, 600, "Sample Window")

  window.on_keyboard do |char, x, y|
    puts "keyboard"
  end

  window.on_mouse do |button, state, x, y|
    puts "mouse"
  end

  window.on_render do
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
  end

end
