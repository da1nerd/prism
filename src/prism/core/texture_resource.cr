require "lib_gl"
require "./reference_counter.cr"

module Prism::Core
  # Manages the state of a single GL texture.
  #
  # Keeps track of references to a single GL texture
  # and performs cleanup operations during garbage collection
  class TextureResource < ReferenceCounter
    @id : LibGL::UInt

    getter id

    def initialize
      LibGL.gen_textures(1, out @id)
    end

    # garbage collection
    def finalize
      LibGL.delete_textures(1, pointerof(@id))
    end
  end
end
