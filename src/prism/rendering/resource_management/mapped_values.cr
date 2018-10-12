require "../../core/vector3f"

module Prism
  # Gives the ability safely set and retrive values on a class
  abstract class MappedValues
    @vector3f_map : Hash(String, Vector3f)
    @float32_map : Hash(String, Float32)

    def initialize
      @vector3f_map = {} of String => Vector3f
      @float32_map = {} of String => Float32
    end

    def add_vector(name : String, texture : Vector3f)
      @vector3f_map[name] = texture
    end

    def get_vector(name : String) : Vector3f
      if @vector3f_map.has_key?(name)
        @vector3f_map[name]
      else
        Vector3f.new(0f32, 0f32, 0f32)
      end
    end

    def add_float(name : String, texture : Float32)
      @float32_map[name] = texture
    end

    def get_float(name : String) : Float32
      if @float32_map.has_key?(name)
        @float32_map[name]
      else
        0f32
      end
    end
  end
end
