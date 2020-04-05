require "annotation"
require "./texture"
require "./uniform"

module Prism
  class Material
    include Uniform::Serializable
    include Uniform

    property specular_intensity, specular_power

    @[Uniform::Field(key: "specularIntensity")]
    @specular_intensity : Float32 = 1
    @[Uniform::Field(key: "specularPower")]
    @specular_power : Float32 = 8
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
    end

    def add_texture(name : String, texture : Texture)
      @texture_map[name] = texture
    end

    @[Override]
    private def on_to_uniform : UniformMap | Nil
      # manually register the texture sampler slots
      sampler_slot : Int32 = 0
      map = UniformMap.new
      @texture_map.each do |key, texture|
        map[key] = sampler_slot
        sampler_slot += 1
      end
      map
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
