@[Link(ldflags: "#{__DIR__}/libfreeglut_context.a")]
lib LibGluc
  fun display_func = glutDisplayFuncWithContext(callback : Void* -> Void, data : Void*) : Void
  fun close_func = glutCloseFuncWithContext(callback : Void* -> Void, data : Void*) : Void
  fun keyboard_func = glutKeyboardFuncWithContext(callback : (Void*, LibC::Char, LibC::Int, LibC::Int) -> Void, data : Void*) : Void
  fun mouse_func = glutMouseFuncWithContext(callback : (Void*, LibC::Int, LibC::Int, LibC::Int, LibC::Int) -> Void, data : Void*) : Void
  fun motion_func = glutMotionFuncWithContext(callback : (Void*, LibC::Int, LibC::Int) -> Void, data : Void*) : Void
  fun passive_motion_func = glutPassiveMotionFuncWithContext(callback : (Void*, LibC::Int, LibC::Int) -> Void, data : Void*) : Void
end
