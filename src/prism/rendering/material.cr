require "./texture"
require "./resource_management/mapped_values"

module Prism
  class Material < MappedValues
    @texture_map : Hash(String, Texture)

    def initialize
      super
      @texture_map = {} of String => Texture
    end

    def add_texture(name : String, texture : Texture)
      @texture_map[name] = texture
    end

    def get_texture(name : String) : Texture
      if @texture_map.has_key?(name)
        @texture_map[name]
      else
        # TODO: return a default texture
        Texture.new("test.png")
      end
    end
  end
end
