require "../src/prism"
require "lib_gl"
require "lib_glut"

#  Example creating a window
module Examples

  class MainComponent

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
        puts "starting display"
        run()
      end

    end

    # Starts the game
    def start
      @window.open
    end

    # Stops the game
    def stop

    end

    # Main game loop
    def run
      frame_time = 1.0 / FRAME_CAP
      last_time = Prism::Timer.get_time()
      puts "running at #{last_time}"
      unprocessed_time : Float64 = 0
      puts "running"
      while !@window.is_close_requested
        should_render = false
        start_time = Prism::Timer.get_time()
        passed_time = start_time - last_time
        last_time = start_time

        unprocessed_time += passed_time / Prism::Timer::SECOND
        puts "wait"
        while unprocessed_time > frame_time
          puts "render #{unprocessed_time / frame_time}"
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

    # Performs game rendering
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

      @window.render
    end

    # Cleans up after the game quits
    def clean_up

    end
  end

  game = MainComponent.new
  game.start
end
