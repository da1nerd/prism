require "annotation"
require "./texture"
require "./shader"

module Prism::Core
  class Material
    include Shader::Serializable

    property specular_intensity, specular_power, color, use_fake_lighting

    # Indicates that this material has transparency
    setter has_transparency

    # Indicates if this material has transparency
    @has_transparency : Bool = false

    # This allows you to simulate some half decent lighting.
    # This is helpful when rendering entities that are composed of a bunch of flat meshes. e.g. plants, trees, etc.
    @[Shader::Field(key: "useFakeLighting")]
    @use_fake_lighting : Bool = false

    # The reflectivity determines how shiny the surface of the object is.
    @[Shader::Field(key: "specularIntensity")]
    @specular_intensity : Float32 = 1

    # The shine dampening determines how close the camera has to be
    # to the reflected light to see any change in the brightness on surface of the object.
    @[Shader::Field(key: "specularPower")]
    @specular_power : Float32 = 10

    @texture_map : Hash(String, Texture)

    # The color of the surface of the object.
    # this defaults to black
    @[Shader::Field(key: "materialColor")]
    @color : Vector3f = Vector3f.new(0, 0, 0)

    def initialize
      super
      @texture_map = {} of String => Texture
      # add blank texture
      add_texture("diffuse", Texture.new)
    end

    def initialize(texture_path : File)
      super()
      @texture_map = {} of String => Texture
      add_texture("diffuse", Texture.new(texture_path))
    end

    # Creates a material with a "diffuse" texture loaded from the *texture_path*
    # There should be a matching "diffuse" uniform in your shader program.
    def initialize(texture_path : String)
      super()
      @texture_map = {} of String => Texture
      add_texture("diffuse", Texture.new(texture_path))
    end

    # Checks if this material has any transparency
    def has_transparency?
      @has_transparency
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
