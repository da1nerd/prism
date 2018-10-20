require "../src/prism"

include Prism

class LevelMap < GameComponent
  SPOT_WIDTH   = 1f32
  SPOT_LENGTH  = 1f32
  SPOT_HEIGHT  = 1f32
  NUM_TEX_EXP  =    4
  NUM_TEXTURES = 2**NUM_TEX_EXP

  @mesh : Mesh?
  @level : Bitmap
  @material : Material
  @walls : Array(Vector2f)

  def initialize(levelName : String, textureName : String)
    @walls = [] of Vector2f
    @level = Bitmap.new(levelName).flip_y
    @material = Material.new
    @material.add_texture("diffuse", Texture.new(textureName))
    @material.add_float("specularIntensity", 1)
    @material.add_float("specularPower", 8)
    generate_level
  end

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

  def generate_level
    vertices = [] of Vertex
    indices = [] of LibGL::Int

    # build level texture
    0.upto(@level.width - 1) do |i|
      0.upto(@level.height - 1) do |j|
        if @level.pixel(i, j).black?
          @walls.push(Vector2f.new(i.to_f32, j.to_f32))
          next
        end

        tex_coords = calc_tex_coords(@level.pixel(i, j).green) # floor and ceiling textures follow the green channel

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

  # Checks if a collision occured and stops movement along the appropriate axis.
  def check_collision(old_pos : Vector3f, new_pos : Vector3f, object_width : Float32, object_length : Float32) : Vector3f
    collision_vector = Vector2f.new(1, 1)
    movement_vector = new_pos - old_pos

    if movement_vector.length > 0
        block_size = Vector2f.new(SPOT_WIDTH, SPOT_LENGTH)
        object_size = Vector2f.new(object_width, object_length)

        0.upto(@walls.size - 1) do |i|
          collision_vector = collision_vector * rect_collide(old_pos.xz, new_pos.xz, object_size, block_size * @walls[i], block_size)
        end
    end

    return Vector3f.new(collision_vector.x, 0, collision_vector.y)
  end

  private def rect_collide(old_pos : Vector2f, new_pos : Vector2f, player_size : Vector2f, obj_pos : Vector2f, obj_size : Vector2f) : Vector2f
    result = Vector2f.new(0, 0)

    # x axis
    # players right edge < objects left edge || players left edge > object's right edge
    x_can_move = new_pos.x + player_size.x < obj_pos.x || new_pos.x - player_size.x > obj_pos.x + obj_size.x * obj_size.x
    y_can_move = old_pos.y + player_size.y < obj_pos.y || old_pos.y - player_size.y > obj_pos.y + obj_size.y * obj_size.y
    if x_can_move || y_can_move
      result.x = 1f32
    end


    distance_to_right_edge = obj_pos.x - (old_pos.x + player_size.x)
    distance_to_left_edge = (old_pos.x - player_size.x) - (obj_pos.x + obj_size.x * obj_size.x)

    # y axis
    x_can_move = old_pos.x + player_size.x < obj_pos.x || old_pos.x - player_size.x > obj_pos.x + obj_size.x * obj_size.x
    y_can_move = new_pos.y + player_size.y < obj_pos.y || new_pos.y - player_size.y > obj_pos.y + obj_size.y * obj_size.y
    if x_can_move || y_can_move
      result.y = 1f32
    end

    return result
  end

end