require "lib_gl"
require "./bitmap.cr"

module Prism
  # Represents a texture that has been loaded into OpenGL
  class Texture
    ReferencePool.create_persistent_pool(Texture)

    # Creates a new texture
    def initialize(@id : UInt32, @pool_key : String)
    end

    def finalize
      LibGL.delete_textures(1, pointerof(@id))
    end

    # Returns the OpenGL texture id
    def id
      return @id
    end

    # Binds to the first sampler slot (0)
    # DEPRECATED
    def bind
      bind(0)
    end

    # Binds the texture to a sampler slot
    # Valid slots range from 0 to 31.
    def bind(sampler_slot : LibGL::Int)
      if sampler_slot < 0 || sampler_slot > 31
        puts "Error: Sampler slot #{sampler_slot} is out of bounds"
      end
      LibGL.active_texture(LibGL::TEXTURE0 + sampler_slot)
      LibGL.bind_texture(LibGL::TEXTURE_2D, @id)
    end

    # Loads a new texture.
    # Textures that have already been loaded will be re-used.
    def self.load(file_name : String) : Prism::Texture
      if !pool.has_key? file_name
        pool.add(file_name, load_texture(file_name))
      end
      return pool.use file_name
    end

    # Loads a texture into opengl
    private def self.load_texture(file_name : String) : Texture
      # read texture data
      bitmap = Bitmap.new(file_name)

      # create texture
      LibGL.gen_textures(1, out texture_id)
      LibGL.bind_texture(LibGL::TEXTURE_2D, texture_id)

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

      # close the texture
      LibGL.bind_texture(LibGL::TEXTURE_2D, 0)
      return Texture.new(texture_id, file_name)
    end
  end
end
