require "../components/game_component"
require "./transform"
require "../rendering/rendering_engine"
require "./input"

module Prism
  # Represents an object within the scene graph.
  # The screen graph is composed of a tree of `GameObject`s.
  class GameObject
    @children : Array(GameObject)
    @components : Array(GameComponent)
    @transform : Transform
    @engine : CoreEngine?

    getter transform

    def initialize
      @children = [] of GameObject
      @components = [] of GameComponent
      @transform = Transform.new
    end

    # Adds a child `GameObject` to this object
    # The child will inherit certain attributes of the parent
    # such as transformation.
    def add_child(child : GameObject)
      @children.push(child)
      if engine = @engine
        child.engine = engine
      end
      child.transform.parent = @transform
    end

    # Adds a `GameComponent` to this object
    def add_component(component : GameComponent)
      component.parent = self
      @components.push(component)
      return self
    end

    # Performs input update logic on this object and it's children
    def input(delta : Float32, input : Input)
      @transform.update

      0.upto(@components.size - 1) do |i|
        @components[i].input(delta, input)
      end

      0.upto(@children.size - 1) do |i|
        @children[i].input(delta, input)
      end
    end

    # Performs game update logic on this object and it's children
    def update(delta : Float32)
      0.upto(@components.size - 1) do |i|
        @components[i].update(delta)
      end

      0.upto(@children.size - 1) do |i|
        @children[i].update(delta)
      end
    end

    # Performs rendering operations on this object and it's children
    def render(shader : Shader, rendering_engine : RenderingEngineProtocol)
      0.upto(@components.size - 1) do |i|
        @components[i].render(shader, rendering_engine)
      end

      0.upto(@children.size - 1) do |i|
        @children[i].render(shader, rendering_engine)
      end
    end

    # Sets the `CoreEngine` on this object
    # This allows the object and it's children to interact with the engine
    def engine=(engine : CoreEngine)
      if @engine != engine
        @engine = engine

        0.upto(@components.size - 1) do |i|
          @components[i].add_to_engine(engine)
        end
  
        0.upto(@children.size - 1) do |i|
          @children[i].engine = engine
        end
      end
    end
  end
end
