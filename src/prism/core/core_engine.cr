require "cryst_glut"
require "./timer"
require "./input"
require "../rendering/render_util"
require "../../game/game"

module Prism

  class CoreEngine

    @frametime : Float32

    def initialize(@width : Int32, @height : Int32, @framerate : Float32, @title : String, @game : Game)

      # set up window
      @window = CrystGLUT::Window.new(@width, @height, "TITLE")
      init_rendering

      @is_running = false
      @frametime = 1.0f32 / @framerate

      @window.on_display do
        run()
      end

      @input = Input.new(@window)
    end

    def init_rendering
      puts RenderUtil.get_open_gl_version
      RenderUtil.init_graphics
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

      @game.init

      last_time = Timer.get_time()
      unprocessed_time : Float64 = 0.0

      while running = @is_running

        should_render = false
        start_time = Timer.get_time()
        passed_time = start_time - last_time # how long the previous frame took
        last_time = start_time

        unprocessed_time += passed_time / Timer::SECOND
        frame_counter += passed_time

        while unprocessed_time > @frametime
          should_render = true

          unprocessed_time -= @frametime

          if @window.is_close_requested
            stop()
          end

          Timer.set_delta(@frametime);

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
