require "../src/prism"
require "./obstacle.cr"
require "./door.cr"
require "./wall.cr"
require "./collision_detector.cr"
require "./monster.cr"
require "./monster_look.cr"

include Prism

class LevelMap < GameComponent
  SPOT_WIDTH                = 1f32
  SPOT_LENGTH               = 1f32
  SPOT_HEIGHT               = 1f32
  NUM_TEX_EXP               =    4
  NUM_TEXTURES              = 2**NUM_TEX_EXP
  DOOR_OPEN_MOVEMENT_AMOUNT = 0.9f32
  DOOR_OPEN_DISTANCE = 2.5f32

  @mesh : Mesh?
  @level : Bitmap
  @wall_material : Material
  @obstacles : Array(Obstacle)
  @objects : Array(GameObject)
  @doors : Array(Door)
  @collision_pos_start : Array(Vector2f)
  @collision_pos_end : Array(Vector2f)
  @monsters : Array(Monster)

  getter objects

  def initialize(level_name : String, wall_texture_name : String)
    @doors = [] of Door
    @objects = [] of GameObject
    @obstacles = [] of Obstacle
    @monsters = [] of Monster
    @collision_pos_start = [] of Vector2f
    @collision_pos_end = [] of Vector2f

    level_path = File.join("/res/bitmaps/", level_name)
    @level = Bitmap.new(level_path).flip_y

    @wall_material = Material.new
    @wall_material.add_texture("diffuse", Texture.new(wall_texture_name))
    @wall_material.add_float("specularIntensity", 1)
    @wall_material.add_float("specularPower", 8)

    collision_detector = CollisionDetector.new(@obstacles)

    # TODO: orient the player based on the level data
    @player = Player.new(Vector2f.new(7, 7), collision_detector)
    @player.set_level(self)
    @objects.push(@player)
    self.generate_level

    # TODO: monster should be a game object with components handled internally
    monster_component = Monster.new(collision_detector)
    monster_component.set_level(self)
    monster = GameObject.new.add_component(MonsterLook.new).add_component(monster_component)
    monster.transform.pos = Vector3f.new(12, 0, 12)
    @objects.push(monster)
    @monsters.push(monster_component)
    # @obstacles.push(monster_component)
  end

  # Add a face on the level such as a wall or ceiling.
  private def add_face(indices : Array(Int32), start_location : Int32, direction : Bool)
    if direction
      indices.push(start_location + 2)
      indices.push(start_location + 1)
      indices.push(start_location + 0)
      indices.push(start_location + 3)
      indices.push(start_location + 2)
      indices.push(start_location + 0)
    else
      indices.push(start_location + 0)
      indices.push(start_location + 1)
      indices.push(start_location + 2)
      indices.push(start_location + 0)
      indices.push(start_location + 2)
      indices.push(start_location + 3)
    end
  end

  # calculate floor texture coordinates based on the level's green channel
  #
  # Textures are assigned by the level color.
  # Choose a texture from the texture collection (position 0 starts in bottom right corner and moves up)
  # and multiply it's position by the total number of textures e.g. to access texture 2 in a 16 texture block
  # set the appropriate color value to 2*16 or 32
  private def calc_tex_coords(color_channel : UInt8) : StaticArray(Float32, 4)
    tex_x : UInt8 = color_channel / NUM_TEXTURES # tex row
    tex_y : UInt8 = tex_x % NUM_TEX_EXP          # tex column
    tex_x /= NUM_TEX_EXP

    x_higher = 1 - tex_x.to_f32 / NUM_TEX_EXP
    x_lower = x_higher - 1f32 / NUM_TEX_EXP
    y_lower = 1 - tex_y.to_f32 / NUM_TEX_EXP
    y_higher = y_lower - 1f32 / NUM_TEX_EXP

    return StaticArray[
      x_higher,
      x_lower,
      y_higher,
      y_lower,
    ]
  end

  private def add_verticies(vertices : Array(Prism::Vertex), i : Int32, j : Int32, offset : Int32, x : Bool, y : Bool, z : Bool, tex_coords : Array(Float32))
    x_higher, x_lower, y_higher, y_lower = tex_coords
    if x && z
      vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, offset * SPOT_HEIGHT, j * SPOT_LENGTH), Vector2f.new(x_lower, y_lower)))
      vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, offset * SPOT_HEIGHT, j * SPOT_LENGTH), Vector2f.new(x_higher, y_lower)))
      vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, offset * SPOT_HEIGHT, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_higher)))
      vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, offset * SPOT_HEIGHT, (j + 1) * SPOT_LENGTH), Vector2f.new(x_lower, y_higher)))
    elsif x && y
      vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, j * SPOT_HEIGHT, offset * SPOT_LENGTH), Vector2f.new(x_lower, y_lower)))
      vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, j * SPOT_HEIGHT, offset * SPOT_LENGTH), Vector2f.new(x_higher, y_lower)))
      vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, (j + 1) * SPOT_HEIGHT, offset * SPOT_LENGTH), Vector2f.new(x_higher, y_higher)))
      vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, (j + 1) * SPOT_HEIGHT, offset * SPOT_LENGTH), Vector2f.new(x_lower, y_higher)))
    elsif y && z
      vertices.push(Vertex.new(Vector3f.new(offset * SPOT_WIDTH, i * SPOT_HEIGHT, j * SPOT_LENGTH), Vector2f.new(x_lower, y_lower)))
      vertices.push(Vertex.new(Vector3f.new(offset * SPOT_WIDTH, i * SPOT_HEIGHT, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_lower)))
      vertices.push(Vertex.new(Vector3f.new(offset * SPOT_WIDTH, (i + 1) * SPOT_HEIGHT, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_higher)))
      vertices.push(Vertex.new(Vector3f.new(offset * SPOT_WIDTH, (i + 1) * SPOT_HEIGHT, j * SPOT_LENGTH), Vector2f.new(x_lower, y_higher)))
    else
      puts "Error: Invalid plane used in level generator"
      exit 1
    end
  end

  private def add_door(x : Int32, y : Int32)
    # detect axis
    x_door = @level.pixel(x, y - 1).black? && @level.pixel(x, y + 1).black?
    y_door = @level.pixel(x - 1, y).black? && @level.pixel(x + 1, y).black?

    if !(x_door ^ y_door)
      puts "Error: Level generation has failed! You placed a door in an invalid location at #{x}, #{y}"
      exit 1
    end

    open_movement = Vector3f.new(0, 0, 0)
    if y_door
      open_movement = Vector3f.new(DOOR_OPEN_MOVEMENT_AMOUNT, 0, 0)
    end

    if x_door
      open_movement = Vector3f.new(0, 0, DOOR_OPEN_MOVEMENT_AMOUNT)
    end

    door_component = Door.new(@wall_material, open_movement)
    door = GameObject.new.add_component(door_component)

    if y_door
      door.transform.pos = Vector3f.new(x.to_f32, 0, y.to_f32 + SPOT_LENGTH / 2f32)
    end

    if x_door
      door.transform.pos = Vector3f.new(x + SPOT_WIDTH / 2f32, 0, y.to_f32)
      door.transform.rot = Quaternion.new(Vector3f.new(0, 1, 0), Prism.to_rad(-90f32))
    end

    @objects.push(door)
    @obstacles.push(door_component)
    @doors.push(door_component)
  end

  private def add_special(blue_value : UInt8, x : Int32, y : Int32)
    if blue_value == 16
      add_door(x, y)
    end
  end

  def generate_level
    vertices = [] of Vertex
    indices = [] of LibGL::Int

    # build level texture
    0.upto(@level.width - 1) do |i|
      0.upto(@level.height - 1) do |j|
        if @level.pixel(i, j).black?
          @obstacles.push(Wall.new(Vector3f.new(i.to_f32, 0, j.to_f32), Vector3f.new(SPOT_WIDTH, SPOT_HEIGHT, SPOT_LENGTH)))
          next
        end

        tex_coords = calc_tex_coords(@level.pixel(i, j).green) # floor and ceiling textures follow the green channel

        add_special(@level.pixel(i, j).blue, i, j)

        # generate floor
        add_face(indices, vertices.size, true)
        add_verticies(vertices, i, j, 0, true, false, true, tex_coords.to_a)

        # generate ceiling
        add_face(indices, vertices.size, false)
        add_verticies(vertices, i, j, 1, true, false, true, tex_coords.to_a)

        # generate walls
        tex_coords = calc_tex_coords(@level.pixel(i, j).red) # wall textures follow the red channel

        if @level.pixel(i, j - 1).black?
          @collision_pos_start.push(Vector2f.new(i * SPOT_WIDTH, j * SPOT_LENGTH))
          @collision_pos_end.push(Vector2f.new((i + 1) * SPOT_WIDTH, j * SPOT_LENGTH))
          add_face(indices, vertices.size, false)
          add_verticies(vertices, i, 0, j, true, true, false, tex_coords.to_a)
        end

        if @level.pixel(i, j + 1).black?
          @collision_pos_start.push(Vector2f.new(i * SPOT_WIDTH, (j + 1) * SPOT_LENGTH))
          @collision_pos_end.push(Vector2f.new((i + 1) * SPOT_WIDTH, (j + 1) * SPOT_LENGTH))
          add_face(indices, vertices.size, true)
          add_verticies(vertices, i, 0, (j + 1), true, true, false, tex_coords.to_a)
        end

        if @level.pixel(i - 1, j).black?
          @collision_pos_start.push(Vector2f.new(i * SPOT_WIDTH, j * SPOT_LENGTH))
          @collision_pos_end.push(Vector2f.new(i * SPOT_WIDTH, (j + 1) * SPOT_LENGTH))
          add_face(indices, vertices.size, true)
          add_verticies(vertices, 0, j, i, false, true, true, tex_coords.to_a)
        end

        if @level.pixel(i + 1, j).black?
          @collision_pos_start.push(Vector2f.new((i + 1) * SPOT_WIDTH, j * SPOT_LENGTH))
          @collision_pos_end.push(Vector2f.new((i + 1) * SPOT_WIDTH, (j + 1) * SPOT_LENGTH))
          add_face(indices, vertices.size, false)
          add_verticies(vertices, 0, j, (i + 1), false, true, true, tex_coords.to_a)
        end
      end
    end

    @mesh = Mesh.new(vertices, indices, true)
  end

  def width
    if level = @level
      return level.width
    else
      return 0
    end
  end

  def height
    if level = @level
      return level.height
    else
      return 0
    end
  end

  def update(transform : Transform, delta : Float32)
  end

  # Opens doors near the position
  def open_doors(position : Vector3f)
    0.upto(@doors.size - 1) do |i|
      if (@doors[i].transform.pos - position).length < DOOR_OPEN_DISTANCE
        @doors[i].open
      end
    end
  end

  def render(shader : Shader, rendering_engine : RenderingEngineProtocol)
    if mesh = @mesh
      shader.bind
      shader.update_uniforms(self.transform, @wall_material, rendering_engine)
      mesh.draw
    else
      puts "Error: The level mesh has not been created"
      exit 1
    end
  end

  def obstacles : Array(Obstacle)
    @obstacles
  end

  # Finds the nearest intersection to the start of the line
  def check_intersections(line_start : Vector2f, line_end : Vector2f, hurt_monsters : Bool) : Vector2f?
    nearest_intersection : Vector2f? = nil

    0.upto(@collision_pos_start.size - 1) do |i|
      collision_vector = self.line_intersect(line_start, line_end, @collision_pos_start[i], @collision_pos_end[i])
      nearest_intersection = self.find_nearest_vector(nearest_intersection, collision_vector, line_start)
    end

    0.upto(@doors.size - 1) do |i|
      collision_vector = self.line_intersect_rect(line_start, line_end, @doors[i].position.xz, @doors[i].size.xz)
      nearest_intersection = self.find_nearest_vector(nearest_intersection, collision_vector, line_start)
    end

    # This is super hack (like much of this game)
    if hurt_monsters
      nearest_monster_intersect : Vector2f? = nil
      nearest_monster : Monster? = nil

      0.upto(@monsters.size - 1) do |i|
        collision_vector = self.line_intersect_rect(line_start, line_end, @monsters[i].position.xz, @monsters[i].size.xz)
        nearest_monster_intersect = self.find_nearest_vector(nearest_monster_intersect, collision_vector, line_start)
        if nearest_monster_intersect == collision_vector
          nearest_monster = @monsters[i]
        end
      end

      if nm = nearest_monster
        if nmi = nearest_monster_intersect
          if ni = nearest_intersection
            if (nmi - line_start).length < (ni - line_start).length
              nearest_monster.damage(@player.get_damage)
            end
          else
            nearest_monster.damage(@player.get_damage)
          end
        end
      end

    end

    return nearest_intersection
  end

  # Returns the point at which two lines intersect
  private def line_intersect(line_start1 : Vector2f, line_end1 : Vector2f, line_start2 : Vector2f, line_end2 : Vector2f) : Vector2f?
    line1 = line_end1 - line_start1
    line2 = line_end2 - line_start2
    
    cross = line1.cross(line2)

    # parallel lines never intersect
    return nil if cross == 0

    distance_between_lines = line_start2 - line_start1

    a : Float32 = distance_between_lines.cross(line2) / cross
    b : Float32 = distance_between_lines.cross(line1) / cross

    if 0 < a && a < 1 && 0 < b && b < 1
      return line_start1 + (line1 * a)
    end

    return nil
  end

  def find_nearest_vector(a_vect : Vector2f?, b_vect : Vector2f?, position_relative_to : Vector2f) : Vector2f?
    if b = b_vect
      if a = a_vect
        if (a - position_relative_to).length > (b - position_relative_to).length
          return b
        else
          return a
        end
      else
        return b_vect
      end
    else
      return a_vect
    end
  end

  def line_intersect_rect(line_start : Vector2f, line_end : Vector2f, rect_pos : Vector2f, rect_size : Vector2f) : Vector2f?
    result : Vector2f? = nil

    collision_vector = self.line_intersect(line_start, line_end, rect_pos, Vector2f.new(rect_pos.x + rect_size.y, rect_pos.y))
    result = self.find_nearest_vector(result, collision_vector, line_start)

    collision_vector = self.line_intersect(line_start, line_end, rect_pos, Vector2f.new(rect_pos.x, rect_pos.y + rect_size.y))
    result = self.find_nearest_vector(result, collision_vector, line_start)

    collision_vector = self.line_intersect(line_start, line_end, Vector2f.new(rect_pos.x, rect_pos.y + rect_size.y), rect_pos + rect_size)
    result = self.find_nearest_vector(result, collision_vector, line_start)

    collision_vector = self.line_intersect(line_start, line_end, Vector2f.new(rect_pos.x + rect_size.x, rect_pos.y), rect_pos + rect_size)
    result = self.find_nearest_vector(result, collision_vector, line_start)

    return result
  end

end
