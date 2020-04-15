module Prism::Common::Objects
  class Terrain < Shape
    SIZE            = 800
    MAX_HEIGHT      =  40
    MAX_PIXEL_COLOR = 256 * 256 * 256 # because there are three color channels

    @x : Float32
    @z : Float32

    def initialize(grid_x : Int32, grid_z : Int32, height_map : String)
      super()
      @x = (grid_x * SIZE).to_f32
      @z = (grid_z * SIZE).to_f32
      generate_terrain(height_map)
    end

    def transform
      @transform.pos = Vector3f.new(@x, 0, @z)
      @transform
    end

    private def generate_terrain(height_map : String)
      bitmap = Core::Bitmap.new(height_map)

      vertex_count = bitmap.height

      vertices = [] of Core::Vertex
      indices = [] of Int32
      0.upto(vertex_count - 1) do |i|
        0.upto(vertex_count - 1) do |j|
          vertices.push(Core::Vertex.new(
            # vertex position
            Vector3f.new(
              (j / (vertex_count - 1) * SIZE).to_f32,
              get_height(j, i, bitmap),
              (i / (vertex_count - 1) * SIZE).to_f32
            ),
            # texture coordinates
            Vector2f.new(
              j.to_f32 / (vertex_count - 1) * 40,
              i.to_f32 / (vertex_count - 1) * 40
            ),
            # normals
            calculate_normals(j, i, bitmap)
          ))
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

      @mesh = Core::Mesh.new(vertices, indices)
    end

    def calculate_normals(x : Int32, z : Int32, image : Core::Bitmap) : Vector3f
      height_l = get_height(x - 1, z, image)
      height_r = get_height(x + 1, z, image)
      height_d = get_height(x, z - 1, image)
      height_u = get_height(x, z + 1, image)

      normal = Vector3f.new(height_l - height_r, 2f32, height_d - height_u)
      normal.normalized
    end

    # Returns the height represented by a pixel in the image
    private def get_height(x : Int32, z : Int32, image : Core::Bitmap) : Float32
      return 0f32 if x < 0 || x >= image.height || z < 0 || z >= image.height

      pixel = image.pixel(x, z)
      height : Float32 = -((pixel.red.to_i32 << 16) + (pixel.green.to_i32 << 8) + pixel.blue.to_i32).to_f32
      height += MAX_PIXEL_COLOR / 2f32
      height /= MAX_PIXEL_COLOR / 2f32
      height *= MAX_HEIGHT
      height
    end
  end
end
