require "lib_gl"
require "./input"

module Prism

  class Game

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
    end

    def update

    end

    def render
      LibGL.clear(LibGL::COLOR_BUFFER_BIT | LibGL::DEPTH_BUFFER_BIT)

      LibGL.begin(LibGL::TRIANGLES);
      LibGL.color3f(1, 0, 0);
      LibGL.vertex2f(-0.5, -0.5);
      LibGL.color3f(0, 1, 0);
      LibGL.vertex2f(0.5, -0.5);
      LibGL.color3f(0, 0, 1);
      LibGL.vertex2f(0, 0.5);

      LibGL.end();
      LibGL.flush();
    end

  end

end
