require "./texture"
require "./uniform"

module Prism
  class Material
    include Uniform

    register_uniforms [
      {name: specular_intensity, type: Float32, default: 0},
      {name: specular_power, type: Float32, default: 0},
    ]

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
      self.uniform_specular_intensity = 1f32
      self.uniform_specular_power = 8f32
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
