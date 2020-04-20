module Prism::EntitySystem
  #
  # This internal class maintains a pool of deleted nodes for reuse by the framework. This reduces the overhead
  # from object creation and garbage collection.
  #
  # Because nodes may be deleted from a NodeList while in use, by deleting Nodes from a NodeList
  # while iterating through the NodeList, the pool also maintains a cache of nodes that are added to the pool
  # but should not be reused yet. They are then released into the pool by calling the releaseCache method.
  #
  private class NodePool(T)
    @nodes : Array(Node)
    @node_cache : Array(Node)
    @components : Array(String)

    # Creates a pool for the given node class.
    def initialize(@components : Array(String))
      @nodes = [] of Node
      @node_cache = [] of Node
    end

    #
    # Fetches a node from the pool.
    #
    protected def get : Node
      if @nodes.size < 0
        @nodes.pop
      else
        T.new
      end
    end

    #
    # Adds a node to the pool.
    #
    protected def dispose(node : Node)
      @components.each do |index, component_name|
        node[component_name] = null
      end
      node.entity = Nil
      @nodes.push node
    end

    #
    # Adds a node to the cache
    #
    protected def cache(node : Node)
      @node_cache.push node
    end

    #
    # Releases all nodes from the cache into the pool
    #
    protected def release_cache
      @node_cache.each do |index, node|
        dispose node
      end
      @node_cache.clear
    end
  end
end
