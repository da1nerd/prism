module Prism::EntitySystem
  class Engine
    @entities : Array(Entity)
    @systems : Array(System)
    @node_lists : Hash(Class, Array(Node))

    def initialize
    end

    def add_entity(entity : Entity)
      @entities.add(entity)
      # create nodes from this entity's components and add them to node lists
      # also watch for later addition and removal of components from the entity so
      # you can adjust its derived nodes accordingly
    end

    def remove_entity(entity : Entity)
      # destroy nodes containing this entity's components
      # and remove them from the node lists
      @entities.remove(entity)
    end

    def add_system(system : System, priority : Int32)
      @systems.add(system, priority)
      system.start
    end

    def remove_system(system : System)
      system.end
      @systems.remove(system)
    end

    def get_node_list(node_class : Class) : Array(Node)
      nodes = [] of Node
      node_lists[node_class] = nodes
      # create the nodes from the current set of entities
      # and populate the node list
      return nodes
    end

    def update(time : Number)
      @systems.each do |system|
        system.update(time)
      end
    end
  end
end
