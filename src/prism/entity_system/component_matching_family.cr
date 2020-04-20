require "./family"

module Prism::EntitySystem
  #
  # The default class for managing a NodeList. This class creates the NodeList and adds and removes
  # nodes to/from the list as the entities and the components in the engine change.
  #
  # It uses the basic entity matching pattern of an entity system - entities are added to the list if
  # they contain components matching all the public properties of the node class.
  #
  class ComponentMatchingFamily(T) < Family
    @nodes : Array(Node)
    @entities : Hash(Entity, Node)
    @components : Hash(String, String)
    @node_pool : NodePool(T)
    @engine : Engine

    #
    # The constructor. Creates a ComponentMatchingFamily to provide a NodeList for the
    # given node class.
    #
    # @param nodeClass The type of node to create and manage a NodeList for.
    # @param engine The engine that this family is managing teh NodeList for.
    #
    def initialize(@engine : Engine)
      @nodes = NodeList.new
      @entities = Hash(Entity, Node).new
      @components = Hash(String, String).new
      @node_pool = NodePool(T).new(components)

      @node_pool.dispose(nodePool.get) # create a dummy instance to ensure describeType works.

      # TODO: get list of the components in the class and register them in @components
      # loop over components
      # @components[component_class] = component_name
    end

    #
    # The nodelist managed by this family. This is a reference that remains valid always
    # since it is retained and reused by Systems that use the list. i.e. we never recreate the list,
    # we always modify it in place.
    #
    def node_list : Array(Node)
      @nodes
    end

    #
    # Called by the engine when an entity has been added to it. We check if the entity should be in
    # this family's NodeList and add it if appropriate.
    #
    def new_entity(entity : Entity)
      add_if_match entity
    end

    #
    # Called by the engine when a component has been added to an entity. We check if the entity is not in
    # this family's NodeList and should be, and add it if appropriate.
    #
    def component_added_to_entity(entity : Entity, component_class : String)
      add_if_match entity
    end

    #
    # Called by the engine when a component has been removed from an entity. We check if the removed component
    # is required by this family's NodeList and if so, we check if the entity is in this this NodeList and
    # remove it if so.
    #
    def component_removed_from_entity(entity : Entity, component_class : String)
      if @components.has_key? componentClass
      end
      remove_if_match entity
    end

    #
    # Called by the engine when an entity has been rmoved from it. We check if the entity is in
    # this family's NodeList and remove it if so.
    #
    def remove_entity(entity : Entity)
      remove_if_match entity
    end

    #
    # If the entity is not in this family's NodeList, tests the components of the entity to see
    # if it should be in this NodeList and adds it if so.
    #
    private def add_if_match(entity : Entity)
      if !entities[entity] # check if in array
        @components.each do |key, class_name|
          return unless entity.has component_class
        end

        node : Node = nodePool.get
        node.entity = entity
        @components.each do |key, class_name|
          node[@components[class_name]] = entity.get(class_name)
        end

        @entities[entity] = node
        @nodes.push node
      end
    end

    #
    # Removes the entity if it is in this family's NodeList.
    #
    private def remove_if_match(entity : Entity)
      if @entities[entity]
        node : Node = @entities[entity]
        @entities.delete entity
        @nodes.remove(node)
        if engine.updating
          @node_pool.cache node
          @engine.update_complete.add release_node_pool_cache
        else
          @node_pool.dispose node
        end
      end
    end

    #
    # Releases the nodes that were added to the node pool during this engine update, so they can
    # be reused.
    #
    private def release_node_pool_cache
      @engine.update_complete.remove release_node_pool_cache
      @node_pool.release_cache
    end

    #
    # Removes all nodes from the NodeList.
    #
    def clean_up
      @nodes.each do |index, node|
        @entities.delete node.entity
      end

      @nodes.clear
    end
  end
end
