require "lib_gl"
require "./bitmap.cr"

module Prism
  # TODO: the texture class should just be a light wrapper around the opengl texture id.
  #  Texture atlasing, and loading should be handled elsewhere.
  class Texture
    @@loaded_textures = {} of String => TextureResource
    @resource : TextureResource
    @file_name : String
    @atlas : Prism::TextureAtlas
    getter atlas

    # Creates a blank texture.
    def initialize
      @file_name = ""
      @resource = TextureResource.new
      @atlas = Prism::TextureAtlas.new
    end

    def initialize(file_path : String)
      initialize(file_path, 1)
    end

    # Creates a texture.
    # The *atlas_size* controls how many rows of textures are represented in the *file_name*.
    # A value of 1 means there is on one texture.
    # A value of 2 means there are 4 textures (a 2x2 grid)
    def initialize(@file_name : String, atlas_size : UInt32)
      @atlas = Prism::TextureAtlas.new(atlas_size)
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
        # puts "Trashed texture #{@file_name}"
        @@loaded_textures.delete(@file_name)
      end
    end

    def id
      return @resource.id
    end

    # Binds to the first sampler slot (0)
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
    # TODO: this should be made into static method, and the Texture should just be a wrapper around the OpenGL ids
    private def load_texture(file_path : String) : TextureResource
      # read texture data
      bitmap = Bitmap.new(file_path)

      # create texture
      resource = TextureResource.new
      LibGL.bind_texture(LibGL::TEXTURE_2D, resource.id)

      # wrapping options
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_WRAP_S, LibGL::REPEAT)
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_WRAP_T, LibGL::REPEAT)

      # filtering options
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_MIN_FILTER, LibGL::NEAREST) # NOTE: LibGL::LINEAR is better for higher quality images
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_MAG_FILTER, LibGL::NEAREST)

      format = bitmap.alpha? ? LibGL::RGBA : LibGL::RGB
      LibGL.tex_image_2d(LibGL::TEXTURE_2D, 0, format, bitmap.width, bitmap.height, 0, format, LibGL::UNSIGNED_BYTE, bitmap.pixels)
      LibGL.generate_mipmap(LibGL::TEXTURE_2D)
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_MIN_FILTER, LibGL::LINEAR_MIPMAP_LINEAR)
      LibGL.tex_parameter_f(LibGL::TEXTURE_2D, LibGL::TEXTURE_LOD_BIAS, -0.4)
      return resource
    end
  end
end
