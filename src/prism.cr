require "lib_gl"
require "crystglfw"

include CrystGLFW

# TODO: Write documentation for `Prism`
module Prism
  VERSION = "0.1.0"

  CrystGLFW.run do
    # Request a specific version of OpenGL in core profile mode with forward compatibility.
    hints = {
      CrystGLFW::Window::HintLabel::ContextVersionMajor => 3,
      CrystGLFW::Window::HintLabel::ContextVersionMinor => 3,
      CrystGLFW::Window::HintLabel::OpenGLForwardCompat => true,
      CrystGLFW::Window::HintLabel::OpenGLProfile => CrystGLFW::OpenGLProfile::Core
      # :context_version_major => 3,
      # :context_version_minor => 3,
      # :opengl_forward_compat => true,
      # :opengl_profile => :opengl_core_profile
    }

    # Create a new window.
    window = Window.new(title: "LibGL Rocks!", hints: hints)

    # Make the window the current OpenGL context.
    window.make_context_current

    until window.should_close?
      CrystGLFW.poll_events

      # Use the timer to generate color values.
      time_value = CrystGLFW.time
      red_value = Math.sin(time_value).abs
      green_value = Math.cos(time_value).abs
      blue_value = Math.tan(time_value).abs

      # Clear the window with the generated color.
      LibGL.clear_color(red_value, green_value, blue_value, 1.0)
      LibGL.clear(LibGL::COLOR_BUFFER_BIT)

      window.swap_buffers
    end

    window.destroy
  end
end
