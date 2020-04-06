require "render_loop"
require "crystglfw"

# TODO: this should be in a Prism::Context::GLFW namespace since this is tied
# directly to the context
module Prism::Adapter::GLFW
  alias Key = CrystGLFW::Key
  alias MouseButton = CrystGLFW::MouseButton

  # A window adapter
  class Window < RenderLoop::Window(CrystGLFW::Key, CrystGLFW::MouseButton)
    def initialize(title : String, width : Int32, height : Int32)
      @window = CrystGLFW::Window.new(title: title, width: width, height: height)
    end

    def startup
      @window.make_context_current
    end

    def should_close? : Bool
      @window.should_close?
    end

    def size : RenderLoop::Size
      @window.size
    end

    def size(s : RenderLoop::Size)
    end

    def render
      @window.swap_buffers
    end

    def key_pressed?(k : CrystGLFW::Key) : Bool
      # TRICKY: for some reason these keys are invalid
      return false if k === Key::Unknown || k === Key::ModShift || k === Key::ModAlt || k === Key::ModSuper || k === Key::ModControl
      @window.key_pressed?(k)
    end

    def mouse_button_pressed?(b : CrystGLFW::MouseButton) : Bool
      @window.mouse_button_pressed?(b)
    end

    def cursor_visible=(visible : Bool)
      if visible
        @window.cursor.normalize
      else
        @window.cursor.hide
      end
    end

    def cursor_position : RenderLoop::Position
      @window.cursor.position
    end

    def cursor_position=(position : RenderLoop::Position)
      @window.cursor.position = position
    end

    def destroy
      @window.destroy
    end
  end
end
