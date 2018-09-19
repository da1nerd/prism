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
      @components.push(component)
    end

    def input
      0.upto(@components.size - 1) do |i|
        @components[i].input(@transform)
      end

      0.upto(@children.size - 1) do |i|
        @children[i].input
      end
    end

    def update
      0.upto(@components.size - 1) do |i|
        @components[i].update(@transform)
      end

      0.upto(@children.size - 1) do |i|
        @children[i].update
      end
    end

    def render(shader : Shader)
      0.upto(@components.size - 1) do |i|
        @components[i].render(@transform, shader)
      end

      0.upto(@children.size - 1) do |i|
        @children[i].render(shader)
      end
    end

  end

end
