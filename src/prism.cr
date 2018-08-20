require "lib_gl"

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
end

@[Link("glut")]
lib Glut
  # GLUT API macro definitions -- the display mode definitions
  SINGLE = 0x0000

  fun init = glutInit(argc : Int32, argv : UInt8**) : Void
  fun init_display_mode = glutInitDisplayMode(displayMode : UInt32) : Void
  fun init_window_size = glutInitWindowSize(width: Int32, height: Int32) : Void
  fun init_window_position = glutInitWindowPosition(x: Int32, y : Int32) : Void
  fun create_window = glutCreateWindow(title : UInt8*) : Void
  fun display_func = glutDisplayFunc(callback : Void -> Void) : Void
  fun main_loop = glutMainLoop() : Void
end
