require "lib_gl"
require "./bitmap.cr"

module Prism
  # Represents a texture that has been loaded into OpenGL
  class Texture
    ReferencePool.create_persistent_pool(UInt32) do |key, id|
      # delete the texture
      LibGL.delete_textures(1, pointerof(id))
    end

    # Determines how close the camera has to be to the reflected light to see any change in the brightness on the surface of the texture.
    # This is also known as "specular power."
    # TODO: rather than storing these values here I should repurpose the material class and make it extend texture.
    #  Then in there I can add material properties.
    @shine_damper : Float32 = 1

    # Determines how shiny the surface of the texture is.
    # This is also known as "specular intensity."
    @reflectivity : Float32 = 0

    property shine_damper, reflectivity

    # Returns the texture id.
    # TODO: this is dangerous since we are pooling textures.
    #  However, we need this for now until we can update the texture abstraction.
    getter id

    # Creates a new texture
    def initialize(@id : UInt32, @pool_key : String)
    end

    def finalize
      pool.trash(@pool_key)
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
    # TODO: put this in a texture loader class
    def self.load(file_name : String) : Prism::Texture
      if !pool.has_key? file_name
        pool.add(file_name, load_texture_2d(file_name))
      end

      # produce a texture with the pooled texture id
      Texture.new(pool.use(file_name), file_name)
    end

    # Produces a cube map texture
    # expects *texture_files* to be in the order of:
    # right face, left face, top face, bottom face, back face, front face
    def self.load_cube_map(texture_files : StaticArray(String, 6)) : Prism::Texture
      # reuse from the pool
      pool_key = texture_files.join
      if pool.has_key? pool_key
        return Texture.new(pool.use(pool_key), pool_key)
      end

      LibGL.gen_textures(1, out texture_id)
      # LibGL.active_texture(LibGL::TEXTURE_2D) # need this???
      LibGL.bind_texture(LibGL::TEXTURE_CUBE_MAP, texture_id)

      0.upto(texture_files.size - 1) do |i|
        bitmap = Bitmap.new(texture_files[i])
        format = bitmap.alpha? ? LibGL::RGBA : LibGL::RGB
        # TRICKY: expects files to be in the order of:
        # right face, left face, top face, bottom face, back face, front face
        LibGL.tex_image_2d(LibGL::TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, format, bitmap.width, bitmap.height, 0, format, LibGL::UNSIGNED_BYTE, bitmap.pixels)
      end
      LibGL.tex_parameter_i(LibGL::TEXTURE_CUBE_MAP, LibGL::TEXTURE_MAG_FILTER, LibGL::LINEAR)
      LibGL.tex_parameter_i(LibGL::TEXTURE_CUBE_MAP, LibGL::TEXTURE_MIN_FILTER, LibGL::LINEAR)

      # add to the pool
      pool.add(pool_key, texture_id)
      Texture.new(pool.use(pool_key), pool_key)
    end

    # Loads a texture into opengl
    private def self.load_texture_2d(file_name : String) : UInt32
      # read texture data
      bitmap = Bitmap.new(file_name)

      # create texture
      LibGL.gen_textures(1, out texture_id)
      LibGL.bind_texture(LibGL::TEXTURE_2D, texture_id)

      # wrapping options
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_WRAP_S, LibGL::REPEAT)
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_WRAP_T, LibGL::REPEAT)

      # filtering options
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_MIN_FILTER, LibGL::LINEAR)
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_MAG_FILTER, LibGL::LINEAR)

      format = bitmap.alpha? ? LibGL::RGBA : LibGL::RGB
      LibGL.tex_image_2d(LibGL::TEXTURE_2D, 0, format, bitmap.width, bitmap.height, 0, format, LibGL::UNSIGNED_BYTE, bitmap.pixels)
      LibGL.generate_mipmap(LibGL::TEXTURE_2D)
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_MIN_FILTER, LibGL::LINEAR_MIPMAP_LINEAR)
      LibGL.tex_parameter_f(LibGL::TEXTURE_2D, LibGL::TEXTURE_LOD_BIAS, -0.4)

      # close the texture
      LibGL.bind_texture(LibGL::TEXTURE_2D, 0)
      return texture_id
    end
  end
end
