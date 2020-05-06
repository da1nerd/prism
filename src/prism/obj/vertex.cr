module Prism::OBJ
  class Vertex
    NO_INDEX = -1

    @position : Vector3f
    @texture_index : Int32 = NO_INDEX
    @normal_index : Int32 = NO_INDEX
    @duplicate_vertex : OBJ::Vertex? = nil
    @index : Int32
    @length : Float32

    getter index, length, position, texture_index, normal_index, duplicate_vertex
    setter texture_index, normal_index, duplicate_vertex

    def initialize(@index : Int32, @position : Vector3f)
      @length = @position.length
    end

    def is_set?
      return @texture_index != NO_INDEX && @normal_index != NO_INDEX
    end

    def has_same_texture_and_normal?(texture_index : Int32, normal_index : Int32)
      return texture_index == @texture_index && normal_index == @normal_index
    end
  end
end
