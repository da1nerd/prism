lib LibGlut

  # Initialization functions
  fun init = glutInit(argc : Int32*, argv : UInt8**) : Void
  fun init_window_position = glutInitWindowPosition(x : Int32, y : Int32) : Void
  fun init_window_size = glutInitWindowSize(width : Int32, height : Int32) : Void
  fun init_display_mode = glutInitDisplayMode(displayMode : UInt32) : Void
  fun init_display_string = glutInitDisplayString(displayMode : UInt8*) : Void

  # Process loop function
  fun main_loop = glutMainLoop() : Void

  # Window management functions
  fun create_window = glutCreateWindow(title : UInt8*) : Void
  fun create_sub_window = glutCreateSubWindow(window : Int32, x : Int32, y : Int32, width : Int32, height : Int32) : Void
  fun destroy_window = glutDestroyWindow(window : Int32) : Void
  fun set_window = glutSetWindow(window : Int32) : Void
  fun get_window = glutGetWindow() : Void
  fun set_window_title = glutSetWindowTitle(title : UInt8*) : Void
  fun set_icon_title = glutSetIconTitle(title : UInt8*) : Void
  fun reshape_window = glutReshapeWindow(width : Int32, height : Int32 ) : Void
  fun position_window = glutPositionWindow(x : Int32, y : Int32) : Void
  fun show_window = glutShowWindow() : Void
  fun hide_window = glutHideWindow() : Void
  fun iconify_window = glutIconifyWindow() : Void
  fun push_window = glutPushWindow() : Void
  fun pop_window = glutPopWindow() : Void
  fun full_screen = glutFullScreen() : Void

  # Display-connected functions

  # Mouse cursor functions

  # Menu stuff

  # Global callback functions

  # Window-specific callback functions
  fun display_func = glutDisplayFunc(callback : Void -> Void) : Void

  # State setting and retrieval functions

  # Font stuff

  # Geometry functions

  # Teapot rendering functions
  # front facing polygons have clockwise winding, not counter clockwise

  # Game mode functions

  # Video resize functions

  # Colormap functions

  # Misc keyboard and joystick functions

  # Misc functions

end
