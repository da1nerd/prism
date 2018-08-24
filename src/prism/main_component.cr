require "../crystglut"
require "./timer"
require "./game"
require "./input"

module Prism

  class MainComponent

    WIDTH = 800
    HEIGHT = 600
    TITLE = "3D Engine"
    FRAME_CAP = 500.0 # maximum updates per second

    @is_running = false

    def initialize()

      # set up window
      @window = CrystGLUT::Window.new(WIDTH, HEIGHT, TITLE)

      # @window.on_keyboard do |char, x, y|
      #   puts "key press #{char} #{x} #{y}"
      # end

      # @window.on_mouse do |button, state, x, y|
      #   puts "mouse click #{button} #{state} #{x} #{y}"
      # end

      @window.on_motion do |x, y|

      end

      @window.on_passive_motion do |x, y|

      end

      @window.on_display do
        run()
      end

      @input = Input.new(@window)

      # TODO: make `Game` abstract and pass in an instance through the constructor.
      # set up grame
      @game = Game.new()
      @game.register_input(@input)

    end

    # Starts the game
    def start
      return if running = @is_running == true
      @window.open
    end

    # Stops the game
    def stop
      return if running = @is_running === false
      @is_running = false
    end

    # Main game loop
    private def run
      # TRICKY: for some reason glut is triggering the display function twice
      return if @is_running
      @is_running = true

      frames = 0
      frame_counter = 0;

      frame_time = 1.0 / FRAME_CAP
      last_time = Prism::Timer.get_time()
      unprocessed_time : Float64 = 0.0

      while running = @is_running

        should_render = false
        start_time = Prism::Timer.get_time()
        passed_time = start_time - last_time # how long the previous frame took
        last_time = start_time

        unprocessed_time += passed_time / Prism::Timer::SECOND
        frame_counter += passed_time

        while unprocessed_time > frame_time
          should_render = true

          unprocessed_time -= frame_time

          if @window.is_close_requested
            stop()
          end

          Prism::Timer.set_delta(frame_time);

          @input.update

          @game.input
          @game.update

          # TODO: update game

          # log frame rate
          if(frame_counter >= Prism::Timer::SECOND)
            puts "fps: #{frames}"
            frames = 0
            frame_counter = 0
          end

        end

        if should_render
          render()
          frames += 1;
        else
          # sleep for 1 millisecond
          sleep(Time::Span.new(nanoseconds:1000000))
        end

      end
      clean_up()
    end

    # Performs game rendering
    private def render
      @game.render
      @window.render
    end

    # Cleans up after the game quits
    private def clean_up
      @window.dispose
    end
  end
end
