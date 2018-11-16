require "lib_gl"
require "./resource_management/texture_resource"
require "./bitmap.cr"

module Prism
  class Texture
    @@loaded_textures = {} of String => TextureResource
    @resource : TextureResource
    @file_name : String

    def initialize(@file_name : String)
      if @@loaded_textures.has_key?(@file_name)
        @resource = @@loaded_textures[@file_name]
        @resource.add_reference
      else
        @resource = load_texture(@file_name)
        @@loaded_textures[@file_name] = @resource
      end
    end

    # garbage collection
    def finalize
      if @resource.remove_reference
        @@loaded_textures.delete(@file_name)
      end
    end

    def id
      return @resource.id
    end

    def bind
      bind(0)
    end

    def bind(sampler_slot : LibGL::Int)
      if sampler_slot < 0 || sampler_slot > 31
        puts "Error: Sampler slot #{sampler_slot} is out of bounds"
      end
      LibGL.active_texture(LibGL::TEXTURE0 + sampler_slot)
      LibGL.bind_texture(LibGL::TEXTURE_2D, @resource.id)
    end

    # Loads a texture
    #
    # Returns the gl buffer id
    private def load_texture(file_name : String) : TextureResource
      ext = File.extname(file_name)

      # read texture data
      bitmap = Bitmap.new(File.join("/res/textures/", file_name))
  
      # create texture
      resource = TextureResource.new
      LibGL.bind_texture(LibGL::TEXTURE_2D, resource.id)

      # set the texture wrapping/filtering options
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_WRAP_S, LibGL::REPEAT)
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_WRAP_T, LibGL::REPEAT)
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_MIN_FILTER, LibGL::NEAREST) # LibGL::LINEAR is better for higher quality images
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_MAG_FILTER, LibGL::NEAREST)

      # TODO: I may need to pre multiply RGB with the alpha in order for the blending in the rendering engine to work. (LibGL.blend_func(LibGL::ONE, LibGL::ONE_MINUS_SRC_ALPHA))
      format  = bitmap.alpha? ? LibGL::RGBA : LibGL::RGB
      LibGL.tex_image_2d(LibGL::TEXTURE_2D, 0, format, bitmap.width, bitmap.height, 0, format, LibGL::UNSIGNED_BYTE, bitmap.pixels)
      LibGL.generate_mipmap(LibGL::TEXTURE_2D)
      return resource
    end
  end
end
