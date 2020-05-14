require "lib_gl"
require "annotation"
require "./texture"

module Prism
  class Texture2D < Prism::Texture
    # Determines how close the camera has to be to the reflected light to see any change in the brightness on the surface of the texture.
    # This is also known as "specular power."
    # TODO: rather than storing these values here I should repurpose the material class and make it extend texture.
    #  Then in there I can add material properties.
    @shine_damper : Float32 = 1

    # Determines how shiny the surface of the texture is.
    # This is also known as "specular intensity."
    @reflectivity : Float32 = 0

    property shine_damper, reflectivity

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
