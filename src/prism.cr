require "lib_gl"
require "crystglfw"

include CrystGLFW

def drawTriangle
  # LibGL.color3f(1.0, 1.0, 1.0);
  LibGL.ortho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0);

  LibGL.begin(LibGL::TRIANGLES);
  LibGL.vertex3f(-0.7, 0.7, 0);
  LibGL.vertex3f(0.7, 0.7, 0);
  LibGL.vertex3f(0, -1, 0);
  LibGL.end();

  LibGL.flush();
end

# TODO: Write documentation for `Prism`
module Prism
  VERSION = "0.1.0"

  argv = ARGV.map(&.to_unsafe).to_unsafe
  Glut.init(ARGV.size, argv)
  # Glut.init_display_mode(Glut::SINGLE)
  # Glut.init_window_size(500, 500)
  # Glut.init_window_position(100, 100)
  # Glut.create_window("OpenGL - Creating a triangle")
  #
  # Glut.display_func(drawTriangle)
  # Glut.main_loop()

  # CrystGLFW.run do
  #   # Request a specific version of OpenGL in core profile mode with forward compatibility.
  #   hints = {
  #     CrystGLFW::Window::HintLabel::ContextVersionMajor => 3,
  #     CrystGLFW::Window::HintLabel::ContextVersionMinor => 3,
  #     CrystGLFW::Window::HintLabel::OpenGLForwardCompat => true,
  #     CrystGLFW::Window::HintLabel::OpenGLProfile => CrystGLFW::OpenGLProfile::Core
  #   }
  #
  #   # Create a new window.
  #   window = Window.new(title: "LibGL Rocks!", width: 640, height: 480, hints: hints)
  #   # window.set_position(x : 100, y : 100)
  #
  #   # Make the window the current OpenGL context.
  #   window.make_context_current
  #
  #   until window.should_close?
  #     CrystGLFW.poll_events
  #
  #     # Use the timer to generate color values.
  #     time_value = CrystGLFW.time
  #     red_value = Math.sin(time_value).abs
  #     green_value = Math.cos(time_value).abs
  #     blue_value = Math.tan(time_value).abs
  #
  #     # Clear the window with the generated color.
  #     LibGL.clear_color(red_value, green_value, blue_value, 1.0)
  #     LibGL.clear(LibGL::COLOR_BUFFER_BIT)
  #
  #     # Draw a triangle
  #     drawTriangle
  #
  #     window.swap_buffers
  #   end
  #
  #   window.destroy
  # end
end

@[Link("glut")]
lib Glut
  # GLUT API macro definitions -- the display mode definitions
  # GLUT_RGB                           0x0000
  # GLUT_RGBA                          0x0000
  # GLUT_INDEX                         0x0001
  SINGLE = 0x0000
  # GLUT_DOUBLE                        0x0002
  # GLUT_ACCUM                         0x0004
  # GLUT_ALPHA                         0x0008
  # GLUT_DEPTH                         0x0010
  # GLUT_STENCIL                       0x0020
  # GLUT_MULTISAMPLE                   0x0080
  # GLUT_STEREO                        0x0100
  # GLUT_LUMINANCE                     0x0200

  fun init = glutInit(argc : Int32, argv : UInt8**) : Void
  fun init_display_mode = glutInitDisplayMode(displayMode : UInt32) : Void
  fun init_window_size = glutInitWindowSize(width: Int32, height: Int32) : Void
  fun init_window_position = glutInitWindowPosition(x: Int32, y : Int32) : Void
  fun create_window = glutCreateWindow(title : UInt8*) : Void
  fun display_func = glutDisplayFunc(callback : Void -> Void) : Void
  fun main_loop = glutMainLoop() : Void
end
