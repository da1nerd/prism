require "cryst_glut"
require "./timer"
require "./input"
require "../rendering/rendering_engine"
require "./game"

module Prism

  class CoreEngine

    @frametime : Float64
    @rendering_engine : RenderingEngine

    def initialize(@width : Int32, @height : Int32, @framerate : Float32, @title : String, @game : Game)

      # set up window
      @window = CrystGLUT::Window.new(@width, @height, "TITLE")
      @rendering_engine = RenderingEngine.new(@window)

      @is_running = false
      @frametime = 1.0f64 / @framerate.to_f64

      @window.on_display do
        run()
      end

      @input = Input.new(@window)
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

        unprocessed_time += passed_time
        frame_counter += passed_time

        while unprocessed_time > @frametime
          should_render = true

          unprocessed_time -= @frametime

          if @window.is_close_requested
            stop()
          end

          @game.input(@frametime.to_f32, @input)
          @rendering_engine.input(@frametime.to_f32, @input) # temporary hack
          @input.update

          @game.update(@frametime.to_f32)

          # TODO: update game

          # log frame rate
          if(frame_counter >= 1.0)
            puts "fps: #{frames}"
            frames = 0
            frame_counter = 0
          end

        end

        if should_render
          @rendering_engine.render(@game.get_root_object)
          @window.render
          @rendering_engine.flush
          frames += 1;
        else
          # sleep for 1 millisecond
          sleep(Time::Span.new(nanoseconds:1000000))
        end

      end
      clean_up()
    end

    # Cleans up after the game quits
    private def clean_up
      @window.dispose
    end
  end
end
