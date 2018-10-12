require "../../core/vector3f"
require "../../core/vector2f"

module Prism
  class IndexedModel
    @positions : Array(Vector3f)
    @tex_coords : Array(Vector2f)
    @normals : Array(Vector3f)
    @indicies : Array(Int32)

    getter positions, tex_coords, normals, indicies
    setter positions, tex_coords, normals, indicies

    def initialize
      @positions = [] of Vector3f
      @tex_coords = [] of Vector2f
      @normals = [] of Vector3f
      @indicies = [] of Int32
    end

    def calc_normals
      i = 0
      while i < @indicies.size
        i0 = @indicies[i]
        i1 = @indicies[i + 1]
        i2 = @indicies[i + 2]
        v1 = Vector3f.new(@positions[i1] - @positions[i0])
        v2 = Vector3f.new(@positions[i2] - @positions[i0])

        normal = v1.cross(v2).normalized

        @normals[i0] = @normals[i0] + normal
        @normals[i1] = @normals[i1] + normal
        @normals[i2] = @normals[i2] + normal

        i += 3
      end

      0.upto(@normals.size - 1) do |i|
        @normals[i] = @normals[i].normalized
      end
    end
  end
end
