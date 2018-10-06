require "lib_gl"
require "./input"
require "./game_object"

module Prism

  abstract class Game

    @root : GameObject = GameObject.new

    abstract def init

    def input(delta : Float32, input : Input)
      get_root_object.input(delta, input)
    end

    def update(delta : Float32)
      get_root_object.update(delta)
    end

    def get_root_object : GameObject
      @root
    end
  end

end
