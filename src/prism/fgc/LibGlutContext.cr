@[Link(ldflags: "#{__DIR__}/lib/freeglut_context.a")]
lib LibGlutContext
  fun display_func = glutDisplayFuncWithContext(callback : Void* -> Void, data : Void*) : Void
  fun close_func = glutCloseFuncWithContext(callback : Void* -> Void, data : Void*) : Void
end
