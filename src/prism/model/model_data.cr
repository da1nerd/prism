module Prism
  class ModelData
    @vertices : Array(Float32)
    @texture_coords : Array(Float32)
    @normals : Array(Float32)
    @indices : Array(Int32)
    @furthest_point : Float32

    getter vertices, texture_coords, normals, indices, furthest_point

    def initialize(@vertices, @texture_coords, @normals, @indices, @furthest_point)
    end
  end
end
