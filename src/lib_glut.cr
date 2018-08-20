# Provides language bindings for freeglut
@[Link("glut")]
lib LibGlut
  # GLUT API macro definitions -- the display mode definitions
  SINGLE = 0x0000

  fun init = glutInit(argc : Int32*, argv : UInt8**) : Void
  fun init_display_mode = glutInitDisplayMode(displayMode : UInt32) : Void
  fun init_window_size = glutInitWindowSize(width: Int32, height: Int32) : Void
  fun init_window_position = glutInitWindowPosition(x: Int32, y : Int32) : Void
  fun create_window = glutCreateWindow(title : UInt8*) : Void
  fun display_func = glutDisplayFunc(callback : Void -> Void) : Void
  fun main_loop = glutMainLoop() : Void
end
