module Prism
  # TODO: Turn this into a generator.
  # This shouldn't be an Entity on it's own.
  class Terrain < Prism::Entity
    SIZE            = 800
    MAX_HEIGHT      =  40
    MAX_PIXEL_COLOR = 256 * 256 * 256 # because there are three color channels

    @x : Float32
    @z : Float32
    @heights : Array(Array(Float32))

    getter mesh

    def initialize(grid_x : Int32, grid_z : Int32, height_map : String)
      super()
      @x = (grid_x * SIZE).to_f32
      @z = (grid_z * SIZE).to_f32
      @heights = [] of Array(Float32)
      generate_terrain(height_map)
      add Transform.new.move_to(grid_x.to_f32 * SIZE, 0f32, grid_z.to_f32 * SIZE)
    end

    def transform
      # Force position of terrain
      @transform.pos = Vector3f.new(@x, 0, @z)
      @transform
    end

    def height_at(object : Prism::Entity)
      height_at(object.get(Prism::Transform).as(Prism::Transform).pos)
    end

    def height_at(position : Vector3f) : Float32
      height_at(position.x, position.z)
    end

    # Retrieves the height of the terrain at the given world position.
    def height_at(world_x : Float32, world_z : Float32) : Float32
      terrain_x = world_x - @x
      terrain_z = world_z - @z
      grid_square_size = SIZE.to_f32 / (@heights.size - 1)
      grid_x : Int32 = (terrain_x / grid_square_size).floor.to_i32
      grid_z : Int32 = (terrain_z / grid_square_size).floor.to_i32
      return 0f32 if grid_x >= @heights.size - 1 || grid_z >= @heights.size - 1 || grid_x < 0 || grid_z < 0
      x_coord = (terrain_x % grid_square_size) / grid_square_size
      z_coord = (terrain_z % grid_square_size) / grid_square_size

      if x_coord <= 1 - z_coord
        barryCentric(Vector3f.new(0, @heights[grid_x][grid_z], 0), Vector3f.new(1,
          @heights[grid_x + 1][grid_z], 0), Vector3f.new(0,
          @heights[grid_x][grid_z + 1], 1), Vector2f.new(x_coord, z_coord))
      else
        barryCentric(Vector3f.new(1, @heights[grid_x + 1][grid_z], 0), Vector3f.new(1,
          @heights[grid_x + 1][grid_z + 1], 1), Vector3f.new(0,
          @heights[grid_x][grid_z + 1], 1), Vector2f.new(x_coord, z_coord))
      end
    end

    # TODO: move this into math module
    private def barryCentric(p1 : Vector3f, p2 : Vector3f, p3 : Vector3f, pos : Vector2f) : Float32
      det : Float32 = (p2.z - p3.z) * (p1.x - p3.x) + (p3.x - p2.x) * (p1.z - p3.z)
      l1 : Float32 = ((p2.z - p3.z) * (pos.x - p3.x) + (p3.x - p2.x) * (pos.y - p3.z)) / det
      l2 : Float32 = ((p3.z - p1.z) * (pos.x - p3.x) + (p1.x - p3.x) * (pos.y - p3.z)) / det
      l3 : Float32 = 1.0f32 - l1 - l2
      l1 * p1.y + l2 * p2.y + l3 * p3.y
    end

    private def generate_terrain(height_map : String)
      bitmap = Prism::Bitmap.new(height_map)
      vertex_count = bitmap.height
      # reset height map
      @heights = Array.new(vertex_count) { [] of Float32 }

      vertices = [] of Prism::Vertex
      indices = [] of Int32
      0.upto(vertex_count - 1) do |i|
        0.upto(vertex_count - 1) do |j|
          height = get_height(j, i, bitmap)
          @heights[j] << height
          vertices.push(Prism::Vertex.new(
            # vertex position
            Vector3f.new(
              (j / (vertex_count - 1) * SIZE).to_f32,
              height,
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

      @mesh = Mesh.new(vertices, indices)
    end

    def calculate_normals(x : Int32, z : Int32, image : Prism::Bitmap) : Vector3f
      height_l = get_height(x - 1, z, image)
      height_r = get_height(x + 1, z, image)
      height_d = get_height(x, z - 1, image)
      height_u = get_height(x, z + 1, image)

      normal = Vector3f.new(height_l - height_r, 2f32, height_d - height_u)
      normal.normalized
    end

    # Returns the height represented by a pixel in the image
    private def get_height(x : Int32, z : Int32, image : Prism::Bitmap) : Float32
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
