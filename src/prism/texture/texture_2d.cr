require "lib_gl"
require "annotation"
require "./texture"

module Prism
  class Texture2D < Prism::Texture
    # Binds the texture to a sampler slot
    # Valid slots range from 0 to 31.
    @[Override]
    def bind(sampler_slot : LibGL::Int)
      if sampler_slot < 0 || sampler_slot > 31
        puts "Error: Sampler slot #{sampler_slot} is out of bounds"
      end
      LibGL.active_texture(LibGL::TEXTURE0 + sampler_slot)
      LibGL.bind_texture(LibGL::TEXTURE_2D, @id)
    end
  end
end
