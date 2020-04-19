module Prism::EntitySystem
  class Entity
    @@name_count : Int32 = 0
    # Optional, give the entity a name. This can help with debugging and with serialising the entity.
    @name : String
    @components : Hash(Class, Object)

    def initialize
      initialize ""
    end

    def initialize(name : String)
      @components = new Hash(Class, Object)
      if name
        @name = name
      else
        @@name_count += 1
        @name = "_entity#{@@name_count}"
      end
    end

    def add(component : Object)
      component_class : Class = component.class
      @components[component_class] = component
    end

    def remove(component_class : Class)
      @components.delete component_lass
    end

    def get(component_class : Class) : Object
      return @components[component_class]
    end
  end
end
