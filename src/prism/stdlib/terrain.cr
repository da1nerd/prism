require "crash"
require "annotation"

module Prism
  struct TerrainTexturePack
    getter background, blend_map, red, green, blue

    def initialize(@background : Prism::Texture, @blend_map : Prism::Texture, @red : Prism::Texture, @green : Prism::Texture, @blue : Prism::Texture)
    end
  end

  class ModelData
    TERRAIN_SIZE            = 800
    TERRAIN_MAX_HEIGHT      =  40
    TERRAIN_MAX_PIXEL_COLOR = 256 * 256 * 256 # because there are three color channels

    # Generates a new terrain entity.
    # TODO: this should just create the model data.
    #  The rest of the terrain should be created elsewhere.
    def self.generate_terrain(grid_x : Int32, grid_z : Int32, height_map : String, textures : Prism::TerrainTexturePack) : Prism::Entity
      entity = Prism::Entity.new

      x = (grid_x * TERRAIN_SIZE).to_f32
      z = (grid_z * TERRAIN_SIZE).to_f32
      heights = [] of Array(Float32)
      terrain = generate_terrain_data(height_map)
      transform = Transform.new.move_to(grid_x.to_f32 * TERRAIN_SIZE, 0f32, grid_z.to_f32 * TERRAIN_SIZE)

      entity.add transform
      entity.add Prism::Terrain.new(terrain[:heights], transform, TERRAIN_SIZE.to_f32), Prism::Terrain
      entity.add Prism::Material.new
      entity.add Prism::TexturedTerrainModel.new(terrain[:model], textures)
      entity
    end

    private def self.generate_terrain_data(height_map : String)
      bitmap = Prism::Bitmap.new(height_map)
      vertex_count = bitmap.height
      # reset height map
      heights = Array.new(vertex_count) { [] of Float32 }

      vertices = [] of Float32
      texture_coords = [] of Float32
      normals = [] of Float32
      indices = [] of Int32
      0.upto(vertex_count - 1) do |i|
        0.upto(vertex_count - 1) do |j|
          height = get_height(j, i, bitmap)
          heights[j] << height
          vertices << (j / (vertex_count - 1) * TERRAIN_SIZE).to_f32
          vertices << height
          vertices << (i / (vertex_count - 1) * TERRAIN_SIZE).to_f32
          texture_coords << j.to_f32 / (vertex_count - 1)
          texture_coords << i.to_f32 / (vertex_count - 1)
          norm = calculate_normals(j, i, bitmap)
          normals << norm.x
          normals << norm.y
          normals << norm.z
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

      {
        model:   Prism::Model.load(vertices, texture_coords, normals, indices),
        heights: heights,
      }
    end

    private def self.calculate_normals(x : Int32, z : Int32, image : Prism::Bitmap) : Vector3f
      height_l = get_height(x - 1, z, image)
      height_r = get_height(x + 1, z, image)
      height_d = get_height(x, z - 1, image)
      height_u = get_height(x, z + 1, image)

      normal = Vector3f.new(height_l - height_r, 2f32, height_d - height_u)
      normal.to_normalized
    end

    # Returns the height represented by a pixel in the image
    private def self.get_height(x : Int32, z : Int32, image : Prism::Bitmap) : Float32
      return 0f32 if x < 0 || x >= image.height || z < 0 || z >= image.height

      pixel = image.pixel(x, z)
      height : Float32 = -((pixel.red.to_i32 << 16) + (pixel.green.to_i32 << 8) + pixel.blue.to_i32).to_f32
      height += TERRAIN_MAX_PIXEL_COLOR / 2f32
      height /= TERRAIN_MAX_PIXEL_COLOR / 2f32
      height *= TERRAIN_MAX_HEIGHT
      height
    end
  end

  # Represents some terrain.
  # Since things will probably travel accross this terrain
  # you can check the height at a point on the terrain to properly position other objects.
  #
  # ```
  # height : Float32 = terrain.height_at(entity)
  # ```
  # TODO: This should be turned into a generic hights component, and not store the transform directly.
  class Terrain < Crash::Component
    def initialize(@heights : Array(Array(Float32)), @transform : Prism::Transform, @terrain_size : Float32)
    end

    def height_at(object : Prism::Entity)
      height_at(object.get(Prism::Transform).as(Prism::Transform).pos)
    end

    def height_at(position : Vector3f) : Float32
      height_at(position.x, position.z)
    end

    # Retrieves the height of the terrain at the given world position.
    def height_at(world_x : Float32, world_z : Float32) : Float32
      terrain_x = world_x - @transform.pos.x
      terrain_z = world_z - @transform.pos.z
      grid_square_size = @terrain_size / (@heights.size - 1)
      grid_x : Int32 = (terrain_x / grid_square_size).floor.to_i32
      grid_z : Int32 = (terrain_z / grid_square_size).floor.to_i32
      return 0f32 if grid_x >= @heights.size - 1 || grid_z >= @heights.size - 1 || grid_x < 0 || grid_z < 0
      x_coord = (terrain_x % grid_square_size) / grid_square_size
      z_coord = (terrain_z % grid_square_size) / grid_square_size

      if x_coord <= 1 - z_coord
        Maths.barry_centric_weight(Vector3f.new(0, @heights[grid_x][grid_z], 0), Vector3f.new(1,
          @heights[grid_x + 1][grid_z], 0), Vector3f.new(0,
          @heights[grid_x][grid_z + 1], 1), Vector2f.new(x_coord, z_coord))
      else
        Maths.barry_centric_weight(Vector3f.new(1, @heights[grid_x + 1][grid_z], 0), Vector3f.new(1,
          @heights[grid_x + 1][grid_z + 1], 1), Vector3f.new(0,
          @heights[grid_x][grid_z + 1], 1), Vector2f.new(x_coord, z_coord))
      end
    end
  end
end
