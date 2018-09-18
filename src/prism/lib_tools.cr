# A wrapper around an internal c library so we can quickly write up some code for debugging opengl commands
@[Link(ldflags: "#{__DIR__}/lib/libtools.a")]
lib LibTools
  fun load_png(filename : Pointer(LibC::Char), width : Pointer(LibC::Int), height : Pointer(LibC::Int), color_channels : Pointer(LibC::Int)) : Pointer(LibC::UChar)
end
