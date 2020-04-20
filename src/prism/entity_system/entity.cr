module Prism::EntitySystem
  class Entity
    @@name_count : Int32 = 0
    @name : String
    @components : Hash(Component.class, Component)

    getter name

    def initialize
      initialize ""
    end

    def initialize(name : String)
      @components = Hash(Component.class, Component).new
      if name
        @name = name
      else
        @@name_count += 1
        @name = "_entity#{@@name_count}"
      end
    end

    def add(component : Component)
      @components[component.class] = component
      self
    end

    def remove(component_class : Component.class)
      @components.delete component_lass
      self
    end

    def get(component_class : Component.class) : Component
      return @components[component_class]
    end

    #
    # Does the entity have a component of a particular type.
    #
    # @param componentClass The class of the component sought.
    # @return true if the entity has a component of the type, false if not.
    #
    def has(component_class : Component.class) : Bool
      return @components[component_class] != Nil
    end
  end
end
