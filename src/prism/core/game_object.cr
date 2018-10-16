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

    # Performs input update logic on this object's children
    def input_all(delta : Float32, input : Input)
      input(delta, input)

      0.upto(@children.size - 1) do |i|
        @children[i].input_all(delta, input)
      end
    end

    # Performs game update logic on this object's children
    def update_all(delta : Float32)
      update(delta)

      0.upto(@children.size - 1) do |i|
        @children[i].update_all(delta)
      end
    end

    # Performs rendering operations on this object's children
    def render_all(shader : Shader, rendering_engine : RenderingEngineProtocol)
      render(shader, rendering_engine)

      0.upto(@children.size - 1) do |i|
        @children[i].render_all(shader, rendering_engine)
      end
    end

    # Performs input update logic on this object
    def input(delta : Float32, input : Input)
      @transform.update

      0.upto(@components.size - 1) do |i|
        @components[i].input(delta, input)
      end
    end

    # Performs game update logic on this object
    def update(delta : Float32)
      0.upto(@components.size - 1) do |i|
        @components[i].update(delta)
      end
    end

    # Performs rendering operations on this object
    def render(shader : Shader, rendering_engine : RenderingEngineProtocol)
      0.upto(@components.size - 1) do |i|
        @components[i].render(shader, rendering_engine)
      end
    end

    # Returns an array of all attached objects including it's self
    def get_all_attached : Array(GameObject)
      result = [] of GameObject
      @children.each do |c|
        result.concat(c.get_all_attached)
      end
      result.push(self)
      return result
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
