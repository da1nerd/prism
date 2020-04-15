module Prism::Common::Objects
  class Terrain < Shape
    SIZE         = 800
    VERTEX_COUNT = 128

    @x : Float32
    @z : Float32

    def initialize(grid_x : Int32, grid_z : Int32)
      super()
      @x = (grid_x * SIZE).to_f32
      @z = (grid_z * SIZE).to_f32
      generate_terrain
    end

    def transform
      @transform.pos = Vector3f.new(@x, 0, @z)
      @transform
    end

    private def generate_terrain
      count : Int32 = (VERTEX_COUNT * VERTEX_COUNT).to_i32
      #   verticies = StaticArray(Float32).new(count * 3)
      #   normals = StaticArray(Float32).new(count * 3)
      #   texture_coords = StaticArray(Float32).new(count * 2)
      vertices = [] of Core::Vertex
      indices = [] of Int32 # .new(6 * (VERTEX_COUNT - 1) * (VERTEX_COUNT - 1))
      # vertex_pointer = 0
      0.upto(VERTEX_COUNT) do |i|
        0.upto(VERTEX_COUNT) do |j|
          vertices.push(Core::Vertex.new(
            # vertex position
            Vector3f.new(
              (j // (VERTEX_COUNT - 1) * SIZE).to_f32,
              0f32,
              (i // (VERTEX_COUNT - 1) * SIZE).to_f32
            ),
            # texture coordinates
            Vector2f.new(
              j.to_f32 // (VERTEX_COUNT - 1) * 40,
              i.to_f32 // (VERTEX_COUNT - 1) * 40
            ),
            # normals
            Vector3f.new(0, 1, 0)
          ))
          # vertices[vertex_pointer*3] = j // (VERTEX_COUNT - 1) * SIZE
          # vertices[vertex_pointer*3 + 1] = 0
          # vertices[vertex_pointer*3 + 2] = i // (VERTEX_COUNT - 1) * SIZE
          # normals[vertex_pointer*3] = 0
          # normals[vertex_pointer*3 + 1] = 1
          # normals[vertex_pointer*3 + 2] = 0
          # texture_coords[vertex_pointer*2] = j // (VERTEX_COUNT - 1)
          # texture_coords[vertex_pointer*2 + 1] = i // (VERTEX_COUNT - 1)
          # vertex_pointer += 1
        end
      end

      pointer : Int32 = 0
      0.upto(VERTEX_COUNT - 1) do |gz|
        0.upto(VERTEX_COUNT - 1) do |gx|
          top_left : Int32 = (gz * VERTEX_COUNT) + gx
          top_right : Int32 = top_left + 1
          bottom_left : Int32 = ((gz + 1)*VERTEX_COUNT) + gx
          bottom_right : Int32 = bottom_left + 1
          indices << top_left
          indices << bottom_left
          indices << top_right
          indices << top_right
          indices << bottom_left
          indices << bottom_right
        end
      end

      @mesh = Core::Mesh.new(vertices, indices)
    end
  end
end
