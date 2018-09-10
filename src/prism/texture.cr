require "lib_gl"

module Prism

  class Texture

    getter id

    def initialize(@id : LibGL::UInt)
    end

    def bind
      LibGL.bind_texture(LibGL::TEXTURE_2D, id);
    end
  end

end
