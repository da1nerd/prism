require "../src/prism"
require "lib_gl"

#  Example creating a window
module Example

  class Game

    WIDTH = 800
    HEIGHT = 600
    TITLE = "Sample Window"

    def initialize
      @window = Prism::Window.new(WIDTH, HEIGHT, TITLE)
      @window.on_keyboard do |char, x, y|
        puts "key press #{char} #{x} #{y}"
      end

      @window.on_mouse do |button, state, x, y|
        puts "mouse click #{button} #{state} #{x} #{y}"
      end

      @window.on_motion do |x, y|
      end

      @window.on_passive_motion do |x, y|
      end

      @window.on_display do
        # TODO: render
      end
    end

    def start
      @window.open()
    end

    def stop
    end

    def render
      LibGL.clear(LibGL::COLOR_BUFFER_BIT | LibGL::DEPTH_BUFFER_BIT)

      LibGL.begin(LibGL::TRIANGLES);
      LibGL.color3f(1, 0, 0);
      LibGL.vertex2f(-0.5, -0.5);
      LibGL.color3f(0, 1, 0);
      LibGL.vertex2f(0.5, -0.5);
      LibGL.color3f(0, 0, 1);
      LibGL.vertex2f(0, 0.5);

      LibGL.end();
      LibGL.flush();
    end

  end


  game = Game.new()
  game.start()


end
