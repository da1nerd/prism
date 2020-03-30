require "lib_gl"
require "./game_object"
require "../rendering/rendering_engine_protocol"

module Prism
  # The game interace.
  # A game must inherit this class in order to be used by the engine.
  abstract class Game
    @root : GameObject = GameObject.new

    abstract def init

    # Gives input state to the game
    def input(delta : Float32, input : Prism::Core::Input)
      @root.input_all(delta, input)
    end

    # Requests the game to update state
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

    # Registers the engine with the game
    def engine=(engine : RenderingEngine)
      @root.engine = engine
    end
  end
end
