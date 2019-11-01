require "./texture"
require "./resource_management/mapped_values"

module Prism
  class Material < MappedValues
    @texture_map : Hash(String, Texture)

    def initialize
      super
      @texture_map = {} of String => Texture
    end

    # Creates a material with an initial texture set to default values.
    def initialize(texture_path : String)
      super()
      @texture_map = {} of String => Texture
      add_texture("diffuse", Texture.new(texture_path))
      add_float("specularIntensity", 1)
      add_float("specularPower", 8)
    end

    def add_texture(name : String, texture : Texture)
      @texture_map[name] = texture
    end

    def get_texture(name : String) : Texture
      if @texture_map.has_key?(name)
        @texture_map[name]
      else
        # TODO: return a better default texture
        Texture.new("test.png")
      end
    end
  end
end
