require "../src/prism"
require "lib_gl"
require "lib_glut"

#  Example creating a window
module Examples

  class Game

    WIDTH = 800
    HEIGHT = 600
    TITLE = "Sample Window"
    FRAME_CAP = 5000.0

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
        puts "displaying"
        # run()
      end

    end

    def start

    end

    def stop

    end

    def run
      frame_time = 1.0 / FRAME_CAP
      last_time = Prism::Timer.get_time()
      unprocessed_time : Float64 = 0
      puts "running"
      while true
        should_render = false
        start_time = Prism::Timer.get_time()
        passed_time = start_time - last_time
        last_time = start_time
        puts "hi #{unprocessed_time} #{start_time} #{last_time}"
        unprocessed_time += passed_time / Prism::Timer::SECOND

        while unprocessed_time > frame_time
          puts "hello"
          should_render = true
          unprocessed_time -= frame_time
        end

        if should_render
          render()
        else
          sleep 1
        end

      end
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

      puts "hi"

      LibGL.end();
      LibGL.flush();

      # TODO: this won't work in a class because we can't send context to c
      @window.render
    end

    def clean_up

    end
  end

  game = Game.new
  game.start
end
