require "lib_gl"
require "./resource_management/texture_resource"

module Prism
  class Texture
    @loaded_textures = {} of String => TextureResource
    @resource : TextureResource
    @file_name : String?

    def initialize(file_name : String)
      @file_name = file_name
      if @loaded_textures.has_key?(file_name)
        @resource = @loaded_textures[file_name]
        @resource.add_reference
      else
        @resource = load_texture(file_name)
        @loaded_textures[file_name] = @resource
      end
    end

    # garbage collection
    def finalize
      # TODO: make sure this is getting called
      puts "cleaning up garbage"
      if @resource.remove_reference && @file_name != nil
        @loaded_textures.delete(@file_name)
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
      path = File.join(File.dirname(PROGRAM_NAME), "/res/textures/", file_name)
      data = LibTools.load_png(path, out width, out height, out num_channels)

      # create texture
      resource = TextureResource.new
      LibGL.bind_texture(LibGL::TEXTURE_2D, resource.id)

      # set the texture wrapping/filtering options
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_WRAP_S, LibGL::REPEAT)
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_WRAP_T, LibGL::REPEAT)
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_MIN_FILTER, LibGL::LINEAR)
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_MAG_FILTER, LibGL::LINEAR)

      if data
        LibGL.tex_image_2d(LibGL::TEXTURE_2D, 0, LibGL::RGBA8, width, height, 0, LibGL::RGB, LibGL::UNSIGNED_BYTE, data)
        LibGL.generate_mipmap(LibGL::TEXTURE_2D)
        # TODO: free image data from stbi. see LibTools.
      else
        puts "Error: Failed to load texture data from #{path}"
        exit 1
      end
      return resource
    end
  end
end
