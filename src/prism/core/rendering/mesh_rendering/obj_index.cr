module Prism::Core
  class OBJIndex
    BASE       = 17i32
    MULTIPLIER = 31i32

    @vertex_index : Int32
    @tex_coord_index : Int32
    @normal_index : Int32

    setter vertex_index, tex_coord_index, normal_index
    getter vertex_index, tex_coord_index, normal_index

    def initialize
      @vertex_index = 0
      @tex_coord_index = 0
      @normal_index = 0
    end

    # Returns `true` if this object is equal to *other*.
    def ==(other : Object) : Bool
      return false unless other.is_a?(OBJIndex)

      index = other.as(OBJIndex)
      return @vertex_index == index.vertex_index && @tex_coord_index == index.tex_coord_index && @normal_index == index.normal_index
    end

    # Generates an `Int` hash value for  this object.
    #
    # This has the property that `a == b` implies `a.hash == b.hash`.
    #
    # This is used by the `Hash` class to determine if two objects
    # reference the same hash key
    def hash : Int32
      result = BASE

      result = MULTIPLIER * result + @vertex_index
      result = MULTIPLIER * result + @tex_coord_index
      result = MULTIPLIER * result + @normal_index

      return result
    end
  end
end
