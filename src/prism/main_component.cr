require "cryst_glut"
require "./timer"
require "./game"
require "./input"
require "./render_util"

module Prism

  class MainComponent

    WIDTH = 800
    HEIGHT = 600
    TITLE = "3D Engine"
    FRAME_CAP = 500.0f32 # maximum updates per second

    @is_running = false

    # TODO: make this receive the game instance
    def initialize()

      # set up window
      @window = CrystGLUT::Window.new(WIDTH, HEIGHT, TITLE)

      puts RenderUtil.get_open_gl_version
      RenderUtil.init_graphics

      @window.on_display do
        run()
      end

      @input = Input.new(@window)

      # TODO: make `Game` abstract and pass in an instance through the constructor.
      # set up grame
      @game = Game.new(WIDTH.to_f32, HEIGHT.to_f32)

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

      frame_time = 1.0f32 / FRAME_CAP
      last_time = Timer.get_time()
      unprocessed_time : Float64 = 0.0

      while running = @is_running

        should_render = false
        start_time = Timer.get_time()
        passed_time = start_time - last_time # how long the previous frame took
        last_time = start_time

        unprocessed_time += passed_time / Timer::SECOND
        frame_counter += passed_time

        while unprocessed_time > frame_time
          should_render = true

          unprocessed_time -= frame_time

          if @window.is_close_requested
            stop()
          end

          Timer.set_delta(frame_time);

          @game.input(@input)
          @input.update
          @game.update

          # TODO: update game

          # log frame rate
          if(frame_counter >= Timer::SECOND)
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
      RenderUtil.clear_screen
      @game.render
      @window.render
      RenderUtil.flush
    end

    # Cleans up after the game quits
    private def clean_up
      @window.dispose
    end
  end
end
