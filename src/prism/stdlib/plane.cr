module Prism
  class ModelData
    # Generates a square plane
    def self.generate_plane(size : Int32)
      vertex_count = size

      vertices = [] of Float32
      texture_coords = [] of Float32
      normals = [] of Float32
      indices = [] of Int32
      0.upto(vertex_count - 1) do |i|
        0.upto(vertex_count - 1) do |j|
          height = 0f32
          vertices << (j / (vertex_count - 1) * size).to_f32
          vertices << height
          vertices << (i / (vertex_count - 1) * size).to_f32
          texture_coords << j.to_f32 / (vertex_count - 1)
          texture_coords << i.to_f32 / (vertex_count - 1)
          normals << 0
          normals << 1
          normals << 0
        end
      end

      0.upto(vertex_count - 2) do |gz|
        0.upto(vertex_count - 2) do |gx|
          top_left : Int32 = (gz * vertex_count) + gx
          top_right : Int32 = top_left + 1
          bottom_left : Int32 = ((gz + 1)*vertex_count) + gx
          bottom_right : Int32 = bottom_left + 1
          indices << top_left
          indices << bottom_left
          indices << top_right
          indices << top_right
          indices << bottom_left
          indices << bottom_right
        end
      end

      # TODO: not sure what the furthest point is for.
      Prism::ModelData.new(vertices, texture_coords, normals, indices, 0f32)
    end
  end
end
