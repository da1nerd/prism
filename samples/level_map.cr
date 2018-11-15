require "../src/prism"
require "./obstacle.cr"
require "./door.cr"
require "./wall.cr"
require "./collision_detector.cr"

include Prism

class LevelMap < GameComponent
  SPOT_WIDTH   = 1f32
  SPOT_LENGTH  = 1f32
  SPOT_HEIGHT  = 1f32
  NUM_TEX_EXP  =    4
  NUM_TEXTURES = 2**NUM_TEX_EXP
  DOOR_OPEN_MOVEMENT_AMOUNT = 0.9f32

  @mesh : Mesh?
  @level : Bitmap
  @material : Material
  @obstacles : Array(Obstacle)
  @objects : Array(GameObject)

  getter objects

  def initialize(levelName : String, textureName : String)
    @objects = [] of GameObject
    @obstacles = [] of Obstacle
    @level = Bitmap.new(levelName).flip_y
    @material = Material.new
    @material.add_texture("diffuse", Texture.new(textureName))
    @material.add_float("specularIntensity", 1)
    @material.add_float("specularPower", 8)

    @player = Player.new(Vector2f.new(7, 7), CollisionDetector.new(@obstacles))
    @objects.push(@player)
    generate_level
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
      y_lower
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

    door_component = Door.new(@material, open_movement)
    door = GameObject.new().add_component(door_component)

    if y_door
      door.transform.pos = Vector3f.new(x.to_f32, 0, y.to_f32 + SPOT_LENGTH / 2f32)
    end

    if x_door
      door.transform.pos = Vector3f.new(x + SPOT_WIDTH / 2f32, 0, y.to_f32 + 1)
      door.transform.rot = Quaternion.new(Vector3f.new(0, 1, 0), Prism.to_rad(90f32))
    end

    @objects.push(door)
    @obstacles.push(door_component)
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
          add_face(indices, vertices.size, false)
          add_verticies(vertices, i, 0, j, true, true, false, tex_coords.to_a)
        end

        if @level.pixel(i, j + 1).black?
          add_face(indices, vertices.size, true)
          add_verticies(vertices, i, 0, (j + 1), true, true, false, tex_coords.to_a)
        end

        if @level.pixel(i - 1, j).black?
          add_face(indices, vertices.size, true)
          add_verticies(vertices, 0, j, i, false, true, true, tex_coords.to_a)
        end

        if @level.pixel(i + 1, j).black?
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

  def input(transform : Transform, delta : Float32)
  end

  def door_input(transform : Transform, delta : Float32, player : Player)
  end

  def render(shader : Shader, rendering_engine : RenderingEngineProtocol)
    if mesh = @mesh
      shader.bind
      shader.update_uniforms(self.transform, @material, rendering_engine)
      mesh.draw
    else
      puts "Error: The level mesh has not been created"
      exit 1
    end
  end

  def obstacles : Array(Obstacle)
    @obstacles
  end
end