require "lib_gl"
require "./input"
require "./mesh"
require "./vertex"
require "./vector3f"

module Prism

  class Game

    def initialize
      @mesh = Mesh.new
      #
      # data = [
      #   Vertex.new(Vector3f.new(-1, -1, 0)),
      #   Vertex.new(Vector3f.new(-1, 1, 0)),
      #   Vertex.new(Vector3f.new(0, 1, 0))
      # ]
      #
      # @mesh.add_verticies(data);

    end

    def register_input(@input : Prism::Input)
    end

    def input
      input = @input
      return unless input

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
      @mesh.draw

      # The sample below works, but I want o get the mesh above working.
      # LibGL.clear(LibGL::COLOR_BUFFER_BIT | LibGL::DEPTH_BUFFER_BIT)
      # #
      # LibGL.begin(LibGL::TRIANGLES);
      # LibGL.color3f(1, 0, 0);
      # LibGL.vertex2f(-0.5, -0.5);
      # LibGL.color3f(0, 1, 0);
      # LibGL.vertex2f(0.5, -0.5);
      # LibGL.color3f(0, 0, 1);
      # LibGL.vertex2f(0, 0.5);
      #
      # LibGL.end();
      # LibGL.flush();
    end

  end

end
