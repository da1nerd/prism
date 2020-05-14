require "lib_gl"
require "./texture_2d.cr"
require "./texture_cube_map.cr"
require "./bitmap.cr"

module Prism
  abstract class Texture
    # Loads a cube map texture
    # expects *texture_files* to be in the order of:
    # right face, left face, top face, bottom face, back face, front face
    def self.load_cube_map(texture_files : StaticArray(String, 6)) : Prism::TextureCubeMap
      # reuse from the pool
      pool_key = texture_files.join
      if pool.has_key? pool_key
        return TextureCubeMap.new(pool.use(pool_key), pool_key)
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
      TextureCubeMap.new(pool.use(pool_key), pool_key)
    end

    # Shorthand for `#load_2d`
    def self.load(file_name)
      self.load_2d(file_name)
    end

    # Loads a 2d texture
    def self.load_2d(file_name : String) : Prism::Texture2D
      # reuse from the pool
      pool_key = file_name
      if pool.has_key? pool_key
        return Texture2D.new(pool.use(pool_key), pool_key)
      end

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

      # add to the pool
      pool.add(pool_key, texture_id)
      Texture2D.new(pool.use(pool_key), pool_key)
    end
  end
end
