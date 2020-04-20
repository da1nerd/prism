module Prism::EntitySystem
  class Entity
    @@name_count : Int32 = 0
    @name : String
    @components : Hash(String, Component)

    getter name

    def initialize
      initialize ""
    end

    def initialize(name : String)
      @components = Hash(String, Component).new
      if name
        @name = name
      else
        @@name_count += 1
        @name = "_entity#{@@name_count}"
      end
    end

    def add(component : Component)
      @components[component.class.name] = component
      self
    end

    def remove(component_class : String)
      @components.delete component_lass
      self
    end

    def get(component_class : String) : Component
      return @components[component_class]
    end

    #
    # Does the entity have a component of a particular type.
    #
    # @param componentClass The class of the component sought.
    # @return true if the entity has a component of the type, false if not.
    #
    def has(component_class : String) : Bool
      return @components[component_class] != Nil
    end
  end
end
