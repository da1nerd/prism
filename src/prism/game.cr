require "lib_gl"
require "./input"
require "./mesh"
require "./vertex"
require "./vector3f"
require "./shader"
require "./resource_loader"

module Prism

  # TODO: make this an abstract class
  class Game

    def initialize
      @mesh = Mesh.new
      @shader = Shader.new

      data = [
        Vertex.new(Vector3f.new(-1, -1, 0)),
        Vertex.new(Vector3f.new(0, 1, 0)),
        Vertex.new(Vector3f.new(1, -1, 0))
      ]

      @mesh.add_verticies(data);

      @shader.add_vertex_shader(ResourceLoader.load_shader("basicVertex.vs"))
      # @shader.add_fragment_shader(ResourceLoader.load_shader("basicFragment.fs"))
      @shader.compile
    end

    # Processes input during a frame
    def input(input : Prism::Input)

      if input.get_key_down(Prism::Input::KEY_UP)
        puts "We've just pressed up"
      end
      if input.get_key_up(Prism::Input::KEY_UP)
        puts "We've just released up"
      end

      if input.get_mouse_down(0)
        puts "We've just left clicked at #{input.get_mouse_position.to_string}"
      end
      if input.get_mouse_up(0)
        puts "We've just released the left mouse button"
      end

    end

    def update

    end

    def render
      @shader.bind
      @mesh.draw
    end

  end

end
