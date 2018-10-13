require "lib_gl"
require "./input"
require "./game_object"
require "../rendering/rendering_engine_protocol"

module Prism
  # The game interace.
  # A game must inherit this class in order to be used by the engine.
  abstract class Game
    @root : GameObject = GameObject.new

    abstract def init

    def input(delta : Float32, input : Input)
      @root.input_all(delta, input)
    end

    def update(delta : Float32)
      @root.update_all(delta)
    end

    # Renders the game's scene graph
    def render(rendering_engine : RenderingEngineProtocol)
      rendering_engine.render(@root)
    end

    # Adds an object to the game's scene graph
    def add_object(object : GameObject)
      @root.add_child(object)
    end

    def engine=(engine : CoreEngine)
      @root.engine = engine
    end
  end
end
