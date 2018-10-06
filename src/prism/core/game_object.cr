require "../components/game_component"
require "./transform"
require "../rendering/rendering_engine"
require "./input"

module Prism

  class GameObject

    @children : Array(GameObject)
    @components : Array(GameComponent)
    @transform : Transform

    getter transform

    def initialize()
      @children = [] of GameObject
      @components = [] of GameComponent
      @transform = Transform.new()
    end

    def add_child(child : GameObject)
      @children.push(child)
    end

    def add_component(component : GameComponent)
      component.parent = self
      @components.push(component)
      return self
    end

    def input(delta : Float32, input : Input)
      0.upto(@components.size - 1) do |i|
        @components[i].input(delta, input)
      end

      0.upto(@children.size - 1) do |i|
        @children[i].input(delta, input)
      end
    end

    def update(delta : Float32)
      0.upto(@components.size - 1) do |i|
        @components[i].update(delta)
      end

      0.upto(@children.size - 1) do |i|
        @children[i].update(delta)
      end
    end

    def render(shader : Shader)
      0.upto(@components.size - 1) do |i|
        @components[i].render(shader)
      end

      0.upto(@children.size - 1) do |i|
        @children[i].render(shader)
      end
    end

    def add_to_rendering_engine(rendering_engine : RenderingEngine)
      0.upto(@components.size - 1) do |i|
        @components[i].add_to_rendering_engine(rendering_engine)
      end

      0.upto(@children.size - 1) do |i|
        @children[i].add_to_rendering_engine(rendering_engine)
      end
    end

  end

end
