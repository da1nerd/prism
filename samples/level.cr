require "../src/prism"

include Prism

class Level < GameComponent
  SPOT_WIDTH   = 1f32
  SPOT_LENGTH  = 1f32
  SPOT_HEIGHT  = 1f32
  NUM_TEX_EXP  =    4
  NUM_TEXTURES = 2**NUM_TEX_EXP

  @mesh : Mesh?
  @level : Bitmap
  @material : Material

  def initialize(levelName : String, textureName : String)
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
  private def calc_tex_coords(color_channel : UInt8) : Tuple(Float32, Float32, Float32, Float32)
    tex_x : UInt8 = color_channel / NUM_TEXTURES # tex row
    tex_y : UInt8 = tex_x % NUM_TEX_EXP          # tex column
    tex_x /= NUM_TEX_EXP

    x_higher = 1 - tex_x.to_f32 / NUM_TEX_EXP
    x_lower = x_higher - 1f32 / NUM_TEX_EXP
    y_lower = 1 - tex_y.to_f32 / NUM_TEX_EXP
    y_higher = y_lower - 1f32 / NUM_TEX_EXP

    return {
      x_higher,
      x_lower,
      y_higher,
      y_lower,
    }
  end

  def generate_level
    vertices = [] of Vertex
    indices = [] of LibGL::Int

    # build level texture
    0.upto(@level.width - 1) do |i|
      0.upto(@level.height - 1) do |j|
        if @level.pixel(i, j).black?
          next
        end

        # tex_x : UInt8 = @level.pixel(i, j).green / NUM_TEXTURES # tex row
        # tex_y : UInt8 = tex_x % NUM_TEX_EXP # tex column
        # tex_x /= NUM_TEX_EXP

        # x_higher = 1 - tex_x.to_f32 / NUM_TEX_EXP
        # x_lower = x_higher - 1f32 / NUM_TEX_EXP
        # y_lower = 1 - tex_y.to_f32 / NUM_TEX_EXP
        # y_higher = y_lower - 1f32 / NUM_TEX_EXP

        x_higher, x_lower, y_higher, y_lower = calc_tex_coords(@level.pixel(i, j).green)

        # generate floor
        add_face(indices, vertices.size, true)

        vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, 0, j * SPOT_LENGTH), Vector2f.new(x_lower, y_lower)))
        vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, 0, j * SPOT_LENGTH), Vector2f.new(x_higher, y_lower)))
        vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, 0, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_higher)))
        vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, 0, (j + 1) * SPOT_LENGTH), Vector2f.new(x_lower, y_higher)))

        # generate ceiling
        add_face(indices, vertices.size, false)

        vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, SPOT_HEIGHT, j * SPOT_LENGTH), Vector2f.new(x_lower, y_lower)))
        vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, SPOT_HEIGHT, j * SPOT_LENGTH), Vector2f.new(x_higher, y_lower)))
        vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, SPOT_HEIGHT, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_higher)))
        vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, SPOT_HEIGHT, (j + 1) * SPOT_LENGTH), Vector2f.new(x_lower, y_higher)))

        # generate walls

        # calculate texture coordinates based on the level's red channel
        x_higher, x_lower, y_higher, y_lower = calc_tex_coords(@level.pixel(i, j).red)
        # tex_x = @level.pixel(i, j).red / NUM_TEXTURES
        # tex_y = tex_x % NUM_TEX_EXP
        # tex_x /= NUM_TEX_EXP

        # x_higher = 1 - tex_x.to_f32 / NUM_TEX_EXP
        # x_lower = x_higher - 1f32 / NUM_TEX_EXP
        # y_lower = 1 - tex_y.to_f32 / NUM_TEX_EXP
        # y_higher = y_lower - 1f32 / NUM_TEX_EXP

        if @level.pixel(i, j - 1).black?
          add_face(indices, vertices.size, false)

          vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, 0, j * SPOT_LENGTH), Vector2f.new(x_lower, y_lower)))
          vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, 0, j * SPOT_LENGTH), Vector2f.new(x_higher, y_lower)))
          vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, SPOT_HEIGHT, j * SPOT_LENGTH), Vector2f.new(x_higher, y_higher)))
          vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, SPOT_HEIGHT, j * SPOT_LENGTH), Vector2f.new(x_lower, y_higher)))
        end

        if @level.pixel(i, j + 1).black?
          add_face(indices, vertices.size, true)

          vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, 0, (j + 1) * SPOT_LENGTH), Vector2f.new(x_lower, y_lower)))
          vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, 0, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_lower)))
          vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, SPOT_HEIGHT, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_higher)))
          vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, SPOT_HEIGHT, (j + 1) * SPOT_LENGTH), Vector2f.new(x_lower, y_higher)))
        end

        if @level.pixel(i - 1, j).black?
          add_face(indices, vertices.size, true)

          vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, 0, j * SPOT_LENGTH), Vector2f.new(x_lower, y_lower)))
          vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, 0, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_lower)))
          vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, SPOT_HEIGHT, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_higher)))
          vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, SPOT_HEIGHT, j * SPOT_LENGTH), Vector2f.new(x_lower, y_higher)))
        end

        if @level.pixel(i + 1, j).black?
          add_face(indices, vertices.size, false)

          vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, 0, j * SPOT_LENGTH), Vector2f.new(x_lower, y_lower)))
          vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, 0, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_lower)))
          vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, SPOT_HEIGHT, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_higher)))
          vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, SPOT_HEIGHT, j * SPOT_LENGTH), Vector2f.new(x_lower, y_higher)))
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
end
