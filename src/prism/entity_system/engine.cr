module Prism::EntitySystem
  class Engine
    @entities : Array(Entity)
    @systems : Array(System)
    @node_lists : Hash(String, Array(Node))
    @entity_names : Hash(String, Entity)
    @families : Hash(String, Family)

    def initialize
      @entities = [] of Entity
      @systems = [] of System
      @node_lists = Hash(String, Array(Node)).new
      @entity_names = Hash(String, Entity).new
      @families = Hash(String, Family).new
    end

    def add_entity(entity : Entity)
      if @entity_names.has_key? entity.name
        raise Exception.new("The entity name #{entity.name} is already in use by another entity.")
      end
      @entities.push entity
      @entity_names[entity.name] = entity
      # entity.component_dded.add( componentAdded )
      # entity.componentRemoved.add( componentRemoved );
      # entity.nameChanged.add( entityNameChanged );
      # @node_lists.each do |key, value|
      #   value.
      # end
      @families.each do |key, family|
        family.new_entity entity
      end
    end

    def remove_entity(entity : Entity)
      # destroy nodes containing this entity's components
      # and remove them from the node lists
      @entities.remove(entity)
    end

    def add_system(system : System, priority : Int32)
      system.priority = priority
      system.add_to_engine self
      @systems.push system
    end

    def remove_system(system : System)
      system.end
      @systems.remove(system)
    end

    def get_node_list(node_class : Node.class) : Array(Node)
      # nodes = [] of Node
      # node_lists[node_class] = nodes
      # # create the nodes from the current set of entities
      # # and populate the node list
      # return nodes

      if @families.has_key? node_class
        return @families[node_class].node_ist
      end

      # TODO: later we will allow creating custom families.
      family : Family = ComponentMatchingFamily.new(node_class, self)
      families[node_class] = family

      @entities.each do |index, entity|
        family.new_entity entity
      end
      return family.node_list
    end

    def update(time : Float64)
      @systems.each do |system|
        system.update(time)
      end
    end
  end
end
