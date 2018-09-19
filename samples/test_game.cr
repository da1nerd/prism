require "lib_gl"
require "../src/prism"
require "./mesh_renderer"

include Prism

class TestGame < Prism::Game

  @camera : Camera?
  @transform : Transform?
  @temp : Float32 = 0.0f32
  @root : GameObject

  def initialize(@width : Float32, @height : Float32)
    @root = GameObject.new
  end

  def init
    camera = Camera.new
    @camera = camera

    field_depth = 10.0f32
    field_width = 10.0f32

    verticies = [
      Vertex.new(Vector3f.new(-field_width, 0, -field_depth), Vector2f.new(0, 0)),
      Vertex.new(Vector3f.new(-field_width, 0, field_depth * 3), Vector2f.new(0, 1)),
      Vertex.new(Vector3f.new(field_width * 3, 0, -field_depth), Vector2f.new(1, 0)),
      Vertex.new(Vector3f.new(field_width * 3, 0, field_depth * 3), Vector2f.new(1, 1))
    ]

    indicies = Array(LibGL::Int) {
      0, 1, 2,
      2, 1, 3
    }

    mesh = Mesh.new(verticies, indicies, true);
    material = Material.new(Texture.new("test.png"), Vector3f.new(1,1,1), 1, 8);

    mesh_renderer = MeshRenderer.new(mesh, material)
    @root.add_component(mesh_renderer)

    Transform.set_projection(70f32, @width, @height, 0.1f32, 1_000f32)
    Transform.camera = camera
  end

  # Processes input during a frame
  def input(input : Input)
    # for debugging
    keys = input.get_any_key_down
    if keys.size > 0
      puts "Pressed keys #{keys}"
    end

    if camera = @camera
      camera.input(input)
    end

    @root.input
  end

  def update
    @root.transform.translation(0, -1, 5)
    @root.update
  end

  def render
    @root.render
  end

end
