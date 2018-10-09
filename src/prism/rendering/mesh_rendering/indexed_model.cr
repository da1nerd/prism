require "../../core/vector3f"
require "../../core/vector2f"

module Prism
  class IndexedModel

    @positions : Array(Vector3f)
    @tex_coords : Array(Vector2f)
    @normals : Array(Vector3f)
    @indicies : Array(Int32)

    getter positions, tex_coords, normals, indicies

    def initialize
      @positions = [] of Vector3f
      @tex_coords = [] of Vector2f
      @normals = [] of Vector3f
      @indicies = [] of Int32
    end

  end

end
