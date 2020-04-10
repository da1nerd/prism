require "render_loop"
require "crystglfw"

module Prism::ContextAdapter::GLFW
  alias Key = CrystGLFW::Key
  alias MouseButton = CrystGLFW::MouseButton

  # A window adapter.
  # This binds events to the `CrystGLFW` window.
  class Window < RenderLoop::Window(CrystGLFW::Key, CrystGLFW::MouseButton)
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
