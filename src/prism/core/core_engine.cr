require "crystglfw"
require "./input"
require "../rendering/rendering_engine"
require "./game"

module Prism
  class CoreEngine
    @frametime : Float64
    @rendering_engine : RenderingEngine?

    def initialize(@width : Int32, @height : Int32, @framerate : Float32, @title : String, @game : Game)
      # @window = CrystGLUT::Window.new(@width, @height, @title)
      # @rendering_engine = RenderingEngine.new

      @is_running = false
      @frametime = 1.0f64 / @framerate.to_f64

      # @window.on_display do
      #   run()
      # end
      @game.engine = self
    end

    def rendering_engine : RenderingEngine
      if engine = @rendering_engine
        return engine
      else
        puts "Rendering engine not initialized"
        exit 1
      end
    end

    # Starts the game
    # So long as the game is running this method will not return.
    def start
      return if running = @is_running == true
      CrystGLFW.run do
        self.run
      end
    end

    # Stops the game
    def stop
      return if running = @is_running === false
      @is_running = false
    end

    # Main game loop
    private def run
      return if @is_running
      @is_running = true

      window = CrystGLFW::Window.new(title: @title, width: @width, height: @height)
      window.make_context_current

      input = Input.new(window)
      @rendering_engine = RenderingEngine.new

      frames = 0
      frame_counter = 0
      @game.init

      last_time = Time.monotonic.total_seconds
      unprocessed_time : Float64 = 0.0

      while running = @is_running
        should_render = false
        start_time = Time.monotonic.total_seconds
        passed_time = start_time - last_time # how long the previous frame took
        last_time = start_time

        unprocessed_time += passed_time
        frame_counter += passed_time

        while unprocessed_time > @frametime
          should_render = true

          unprocessed_time -= @frametime

          CrystGLFW.poll_events

          if window.should_close?
            stop()
          end

          @game.input(@frametime.to_f32, input)
          input.update
          @game.update(@frametime.to_f32)

          # log frame rate
          if (frame_counter >= 1.0)
            # puts "fps: #{frames}"
            frames = 0
            frame_counter = 0
          end
        end

        if should_render
          LibGL.viewport(0, 0, window.size[:width], window.size[:height])
          @game.render(rendering_engine)
          # @window.render
          window.swap_buffers
          rendering_engine.flush
          frames += 1
        else
          # sleep for 1 millisecond
          sleep(Time::Span.new(nanoseconds: 1000000))
        end
      end

      window.destroy
      # clean_up()
    end

    # Cleans up after the game quits
    # private def clean_up
    #   @window.dispose
    # end
  end
end
