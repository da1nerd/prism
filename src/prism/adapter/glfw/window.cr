require "render_loop"
require "crystglfw"

module RenderLoop
  class Input(Key, MouseButton)
    @scroll_offset : NamedTuple(x: Float64, y: Float64) = {x: 0f64, y: 0f64}
    @scroll_update : Float64 = 0

    def initialize(@window : RenderLoop::Window(Key, MouseButton))
      bind_scroll
    end

    private def bind_scroll
      @window.window.on_scroll do |event|
        @scroll_update = Time.monotonic.total_seconds
        @scroll_offset = event.offset
      end
    end

    def tick
      previous_def
      # clear the scroll offset after a tenth of a second
      time = Time.monotonic.total_seconds
      if time - @scroll_update > 0.1
        @scroll_offset = {x: 0f64, y: 0f64}
      end
    end

    # Returns the scroll offset
    def get_scroll_offset
      @scroll_offset
    end
  end
end

module Prism::Adapter::GLFW
  # The keyboard key enum.
  # this contains a list of all keys.
  alias Key = CrystGLFW::Key

  # The mouse button enum.
  # This contains a list of all mouse buttons.
  alias MouseButton = CrystGLFW::MouseButton

  # A window adapter.
  # This binds events to the `CrystGLFW` window.
  class Window < RenderLoop::Window(CrystGLFW::Key, CrystGLFW::MouseButton)
    getter window

    def initialize(title : String, width : Int32, height : Int32)
      @window = CrystGLFW::Window.new(title: title, width: width, height: height)
    end

    @[Override]
    def startup
      @window.make_context_current
    end

    @[Override]
    def should_close? : Bool
      @window.should_close?
    end

    @[Override]
    def size : RenderLoop::Size
      @window.size
    end

    @[Override]
    def size(s : RenderLoop::Size)
    end

    @[Override]
    def render
      @window.swap_buffers
    end

    @[Override]
    def key_pressed?(k : CrystGLFW::Key) : Bool
      # TRICKY: for some reason these keys are invalid
      return false if k === Key::Unknown || k === Key::ModShift || k === Key::ModAlt || k === Key::ModSuper || k === Key::ModControl
      @window.key_pressed?(k)
    end

    @[Override]
    def mouse_button_pressed?(b : CrystGLFW::MouseButton) : Bool
      @window.mouse_button_pressed?(b)
    end

    @[Override]
    def cursor_visible=(visible : Bool)
      if visible
        @window.cursor.normalize
      else
        @window.cursor.hide
      end
    end

    @[Override]
    def cursor_position : RenderLoop::Position
      @window.cursor.position
    end

    @[Override]
    def cursor_position=(position : RenderLoop::Position)
      @window.cursor.position = position
    end

    @[Override]
    def destroy
      @window.destroy
    end
  end
end
