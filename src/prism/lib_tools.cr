# A wrapper around an internal c library so we can quickly write up some code for debugging opengl commands
@[Link(ldflags: "#{__DIR__}/libtools.a")]
lib LibTools

end
