require "lib_gl"
require "./input"
require "./game_object"
require "../rendering/rendering_engine_protocol"

module Prism
  abstract class Game
    @root : GameObject = GameObject.new

    abstract def init

    def input(delta : Float32, input : Input)
      @root.input(delta, input)
    end

    # Renders the game's scene graph
    def render(rendering_engine : RenderingEngineProtocol)
      rendering_engine.render(@root)
    end

    # Adds an object to the game's scene graph
    def add_object(object : GameObject)
      @root.add_child(object)
    end

    def update(delta : Float32)
      @root.update(delta)
    end

    def engine=(engine : CoreEngine)
      @root.engine = engine
    end
  end
end
