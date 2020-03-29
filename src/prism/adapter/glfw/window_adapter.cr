require "prism-core"
require "crystglfw"

module Prism::Adapter::GLFW
  alias Key = CrystGLFW::Key

  # A window adapter
  class Window < Prism::Core::Window(CrystGLFW::Key, CrystGLFW::MouseButton)
    def initialize(title : String, width : Int32, height : Int32)
      @window = CrystGLFW::Window.new(title: title, width: width, height: height)
    end

    def should_close? : Bool
      @window.should_close?
    end

    def size : Prism::Core::Size
      @window.size
    end

    def size(s : Prism::Core::Size)
    end

    def render
    end

    def key_pressed?(k : CrystGLFW::Key) : Bool
      # TRICKY: for some reason these keys are invalid
      return false if k === Key::Unknown || k === Key::ModShift || k === Key::ModAlt || k === Key::ModSuper || k === Key::ModControl
      @window.key_pressed?(k)
    end

    def mouse_button_pressed?(b : CrystGLFW::MouseButton) : Bool
      @window.mouse_button_pressed?(b)
    end

    def cursor(c : Prism::Core::Cursor)
      if c.visible
        @window.cursor.normalize
      else
        @window.cursor.hide
      end
    end

    def cursor : Prism::Core::Cursor
      Prism::Core::Cursor.new(@window.cursor.position, true)
    end

    def swap_buffers
      @window.swap_buffers
    end

    def destroy
      @window.destroy
    end
  end
end
