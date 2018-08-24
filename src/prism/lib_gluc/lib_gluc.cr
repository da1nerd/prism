@[Link(ldflags: "#{__DIR__}/libfreeglut_context.a")]
lib LibGluc
  fun display_func = glutDisplayFuncWithContext(callback : Void* -> Void, data : Void*) : Void
  fun close_func = glutCloseFuncWithContext(callback : Void* -> Void, data : Void*) : Void
end
