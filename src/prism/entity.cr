require "crash"
require "./moveable.cr"

module Prism
  # Represents an object within the scene graph.
  # The screen graph is composed of a tree of `Entity`s.
  class Entity < Crash::Entity
    include Prism::Moveable

    @children : Array(Entity)
    @legacy_components : Array(Component)
    @transform : Transform

    getter transform

    def initialize
      super()
      @children = [] of Prism::Entity
      @legacy_components = [] of Component
      @transform = Transform.new
    end

    # Adds a child `Entity` to this object
    # The child will inherit certain attributes of the parent
    # such as transformation.
    def add_object(child : Prism::Entity)
      @children.push(child)
      child.transform.parent = @transform
    end

    # Removes a `Entity` from this object
    def remove_object(child : Prism::Entity)
      @children.delete(child)
      child.transform.parent = nil
    end

    # Alias for add_object
    def add_child(child : Prism::Entity)
      add_object(child)
    end

    # Alias for remove_object
    def remove_child(child : Prism::Entity)
      remove_object(child)
    end

    # Removes a `Component` from this object
    def remove_component(component : Prism::Component)
      remove component
      component.parent = Prism::Entity.new
      @legacy_components.delete(component)
      return self
    end

    # Adds a `Component` to this object
    def add_component(component : Prism::Component)
      add component
      component.parent = self
      @legacy_components.push(component)
      return self
    end

    # Performs input update logic on this object's children
    def input_all(tick : RenderLoop::Tick, input : RenderLoop::Input)
      input(tick, input)

      0.upto(@children.size - 1) do |i|
        @children[i].input_all(tick, input)
      end
    end

    # Performs game update logic on this object's children
    def update_all(tick : RenderLoop::Tick)
      update(tick)

      0.upto(@children.size - 1) do |i|
        @children[i].update_all(tick)
      end
    end

    # Performs rendering operations on this object's children
    #
    # > Warning: the *rendering_engine* property will be deprecated in the future
    def render_all(&block : RenderCallback)
      render(&block)

      0.upto(@children.size - 1) do |i|
        @children[i].render_all(&block)
      end
    end

    # Performs input update logic on this object
    def input(tick : RenderLoop::Tick, input : RenderLoop::Input)
      @transform.update

      0.upto(@legacy_components.size - 1) do |i|
        @legacy_components[i].input(tick, input)
      end
    end

    # Performs game update logic on this object
    def update(tick : RenderLoop::Tick)
      0.upto(@legacy_components.size - 1) do |i|
        @legacy_components[i].update(tick)
      end
    end

    # Performs rendering operations on this object
    #
    # > Warning: the *rendering_engine* property will be deprecated in the future
    def render(&block : RenderCallback)
      0.upto(@legacy_components.size - 1) do |i|
        @legacy_components[i].render(&block)
      end
    end

    # Returns an array of all attached objects including it's self
    def get_all_attached : Array(Prism::Entity)
      result = [] of Prism::Entity
      @children.each do |c|
        result.concat(c.get_all_attached)
      end
      result.push(self)
      return result
    end
  end
end
