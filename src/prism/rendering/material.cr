require "annotation"
require "./texture"
require "./shader/serializable"

module Prism
  class Material
    include Shader::Serializable

    property specular_intensity, specular_power

    @[Shader::Field(key: "specularIntensity")]
    @specular_intensity : Float32 = 1
    @[Shader::Field(key: "specularPower")]
    @specular_power : Float32 = 8
    @texture_map : Hash(String, Texture)

    def initialize
      super
      @texture_map = {} of String => Texture
    end

    # Creates a material with a "diffuse" texture loaded from the *texture_path*
    # There should be a matching "diffuse" uniform in your shader program.
    def initialize(texture_path : String)
      super()
      @texture_map = {} of String => Texture
      add_texture("diffuse", Texture.new(texture_path))
    end

    # Adds a texture to the material
    def add_texture(name : String, texture : Texture)
      @texture_map[name] = texture
    end

    @[Override]
    private def on_to_uniform : Shader::UniformMap | Nil
      # manually register the texture sampler slots
      sampler_slot : Int32 = 0
      map = Shader::UniformMap.new
      @texture_map.each do |key, texture|
        map[key] = sampler_slot
        sampler_slot += 1
      end
      map
    end

    # Retrieves a texture by name
    @[Raises]
    def get_texture(name : String) : Texture
      if @texture_map.has_key?(name)
        @texture_map[name]
      else
        raise Exception.new("Could not find texture '#{name}'. You must add a texture to the material.")
      end
    end

    # Binds the given texture to it's sampler slot
    def bind_texture(name : String)
      sampler_slot : Int32 = 0
      @texture_map.each do |key, texture|
        if key === name
          texture.bind(sampler_slot)
          return
        end
        sampler_slot += 1
      end
    end

    # Checks if the material has a texture.
    def has_texture?(name : String) : Bool
      return @texture_map.has_key?(name)
    end
  end
end
