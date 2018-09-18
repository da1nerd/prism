require "lib_gl"
require "./input"
require "./mesh"
require "./vertex"
require "./vector3f"
require "./shader"
require "./resource_loader"
require "./timer"
require "./transform"
require "./camera"

module Prism

  # TODO: make this an abstract class
  class Game

    @temp : Float32 = 0.0f32

    def initialize(width : Float32, height : Float32)
      @mesh = Mesh.new #ResourceLoader.load_mesh("box.obj") # Mesh.new
      @texture = ResourceLoader.load_texture("test.png")
      @shader = Shader.new
      @camera = Camera.new
      @transform = Transform.new(@camera)
      @transform.set_projection(70f32, width, height, 0.1f32, 1_000f32)

      verticies = [
        Vertex.new(Vector3f.new(-1, -1, 0), Vector2f.new(0, 0)),
        Vertex.new(Vector3f.new(0, 1, 0), Vector2f.new(0.5, 0)),
        Vertex.new(Vector3f.new(1, -1, 0), Vector2f.new(1.0, 0)),
        Vertex.new(Vector3f.new(0, -1, 1), Vector2f.new(0.5, 1.0))
      ]

      indicies = Array(LibGL::Int) {
        3, 1, 0,
        2, 1, 3,
        0, 1, 2,
        0, 2, 3
      }

      @mesh.add_verticies(verticies, indicies);

      @shader.add_vertex_shader(ResourceLoader.load_shader("basicVertex.vs"))
      @shader.add_fragment_shader(ResourceLoader.load_shader("basicFragment.fs"))
      @shader.compile

      @shader.add_uniform("transform")

    end

    # Processes input during a frame
    def input(input : Input)
      keys = input.get_any_key_down
      if keys.size > 0
        puts "Pressed keys #{keys}"
      end
      @camera.input(input)
      # if input.get_key_down(Input::KEY_UP)
      #   puts "We've just pressed up"
      # end
      # if input.get_key_up(Input::KEY_UP)
      #   puts "We've just released up"
      # end
      #
      # if input.get_mouse_down(0)
      #   puts "We've just left clicked at #{input.get_mouse_position.to_string}"
      # end
      # if input.get_mouse_up(0)
      #   puts "We've just released the left mouse button"
      # end

    end

    def update
      delta = Timer.get_delta

      if delta
        @temp += delta
      end

      sinTemp = Math.sin(@temp)

      @transform.translation(0, 0, 5)
      @transform.rotation(0, 180 *sinTemp, 0)
      # @transform.scale(0.7f32 * sinTemp, 0.7f32 * sinTemp, 0.7f32 * sinTemp)
    end

    def render
      RenderUtil.set_clear_color((@camera.pos / 1024).abs)
      @shader.bind
      @shader.set_uniform("transform", @transform.get_projected_transformation)
      @texture.bind
      @mesh.draw
    end

  end

end
