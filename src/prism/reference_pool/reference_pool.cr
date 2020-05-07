module Prism
  # A pool of items which are managed with `Prism::Reference`s.
  # Items in the pool are available for re-use, and items without any references
  # are removed and garbage collected.
  class ReferencePool(T)
    # Generates a new typed reference pool.
    # A private singleton class, and methods will be injected to access the pool.
    # This pool will persist to sub-classes as well.
    macro create_persistent_pool(t)
      # A singleton that provides a pool of `{{t}}`.
      # This pool will persist to sub-classes as well.
      # See `ReferencePool` for details.
      private class {{t}}ReferencePool
          class_getter pool = ReferencePool({{t}}).new
      end

      # Retrieve the `ReferencePool({{t}})` pool associated with this class.
      def self.pool
          {{t}}ReferencePool.pool
      end
    end

    @references : Hash(String, Prism::Reference(T))

    def initialize
      @references = Hash(String, Prism::Reference(T)).new
    end

    # Checks of the pool contains the item
    def has_key?(key : String) : Bool
      @references.has_key? key
    end

    # Retrieves an item from the pool.
    # This will increment the reference counter.
    def use(key) : T
      raise "Item does not exist in the pool: #{key}" unless @references.has_key? key
      @references[key].use
    end

    # Adds an item to the pool.
    # This will set the reference counter to 0.
    # You must then call `#use` to get your first reference.
    # WARNING: do not use the *item* you passed in without calling `#use` or you will mess up the reference counter.
    def add(key : String, item : T)
      raise "Duplicate pool key: #{key}" if @references.has_key? key
      @references[key] = Prism::Reference(T).new(item)
    end

    # Trashes a reference to an item in the pool.
    # The item will be removed from the pool if there are no more references to it.
    def trash(key : String)
      raise "Item does not exist in the pool: #{key}" unless @references.has_key? key
      reference = @references[key]
      reference.trash_one
      @references.delete(key) if reference.is_orphaned?
    end

    # Returns the number of remaining references to the resource
    protected def reference_count(key : String) : Int32
      raise "Item does not exist in the pool: #{key}" unless @references.has_key? key
      @references[key].reference_count
    end

    # Returns how many items are in the pool
    def size : Int32
      @references.size
    end
  end
end
