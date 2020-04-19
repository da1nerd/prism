module Prism::EntitySystem
  class Entity
    @components : Hash(Class, Object)

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
