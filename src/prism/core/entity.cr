# require "./game_component"
# require "./transform"
require "./rendering_engine"
require "./moveable"
require "crash"

module Prism::Core
  # Represents an object within the scene graph.
  # The screen graph is composed of a tree of `Entity`s.
  class Entity < Crash::Entity
    include Core::Moveable

    @children : Array(Core::Entity)
    @legacy_components : Array(Core::Component)
    @transform : Core::Transform
    @engine : Core::RenderingEngine?

    getter transform

    def initialize
      super()
      @children = [] of Core::Entity
      @legacy_components = [] of Core::Component
      @transform = Core::Transform.new
    end

    # Adds a child `Entity` to this object
    # The child will inherit certain attributes of the parent
    # such as transformation.
    def add_object(child : Core::Entity)
      @children.push(child)
      if engine = @engine
        child.engine = engine
      end
      child.transform.parent = @transform
    end

    # Removes a `Entity` from this object
    def remove_object(child : Core::Entity)
      @children.delete(child)
      child.transform.parent = nil
    end

    # Alias for add_object
    def add_child(child : Core::Entity)
      add_object(child)
    end

    # Alias for remove_object
    def remove_child(child : Core::Entity)
      remove_object(child)
    end

    # Removes a `Component` from this object
    def remove_component(component : Core::Component)
      component.parent = Core::Entity.new
      @legacy_components.delete(component)
      return self
    end

    # Adds a `Component` to this object
    def add_component(component : Core::Component)
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
    def get_all_attached : Array(Core::Entity)
      result = [] of Core::Entity
      @children.each do |c|
        result.concat(c.get_all_attached)
      end
      result.push(self)
      return result
    end

    # Sets the `CoreEngine` on this object
    # This allows the object and it's children to interact with the engine
    def engine=(engine : Core::RenderingEngine)
      if @engine != engine
        @engine = engine

        0.upto(@legacy_components.size - 1) do |i|
          @legacy_components[i].add_to_engine(engine)
        end

        0.upto(@children.size - 1) do |i|
          @children[i].engine = engine
        end
      end
    end
  end

  # TODO: this will become the new name. Maybe we should call this an Element instead?
  alias Object = Core::Entity
end
