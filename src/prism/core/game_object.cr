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

    def input(delta : Float32)
      0.upto(@components.size - 1) do |i|
        @components[i].input(@transform, delta)
      end

      0.upto(@children.size - 1) do |i|
        @children[i].input(delta)
      end
    end

    def update(delta : Float32)
      0.upto(@components.size - 1) do |i|
        @components[i].update(@transform, delta)
      end

      0.upto(@children.size - 1) do |i|
        @children[i].update(delta)
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
