@[Link(ldflags: "#{__DIR__}/c/libfreeglut_context.a")]
lib LibFGC
  fun display_func = glutDisplayFuncWithContext(callback : Void* -> Void, data : Void*) : Void
  fun close_func = glutCloseFuncWithContext(callback : Void* -> Void, data : Void*) : Void
end
