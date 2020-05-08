module Prism
  # A pool of items which are managed with `Prism::ReferenceCounter`s.
  # Items in the pool are available for re-use, and items without any references
  # are removed and garbage collected.
  #
  # You should try to pool mostly raw data. E.g. an OpenGL texture id instead of the whole texture class.
  # Because whatever is using the pooled must be able to implement a `finalize` method in which it can `#trash` the pooled item.
  class ReferencePool(T)
    # Generates a new typed `ReferencePool` that is unique to the class (and sub-classes) in which this macro is called.
    # The `ReferencePool` is wrapped in a singleton so that it persists to all sub-classes.
    # The pool itself will be made available from the class method `#pool`.
    #
    # In your `finalize` method you should trash the pooled item so that it's reference can be recovered.
    #
    # ## Example
    #
    # ```
    # def finalize
    #   pool.trash(@pool_key)
    # end
    # ```
    #
    # Where you should be keeping track of the `@pool_key` yourself.
    macro create_persistent_pool(type, &block)
      # A singleton that provides a pool of `{{type}}`.
      # This pool will persist to sub-classes as well.
      # See `ReferencePool` for details.
      private class {{type}}ReferencePool
          @@pool = ReferencePool({{type}}).new {{ block }}
          def self.pool
            @@pool
          end
      end

      # Retrieves the `ReferencePool({{type}})` pool.
      # The pool allows you to re-use `{{type}}`s, and will automatically manage references to each `{{type}}`.
      # See `ReferencePool` for more information.
      def self.pool
          {{type}}ReferencePool.pool
      end

      # Retrieves the `ReferencePool({{type}})` pool.
      # The pool allows you to re-use `{{type}}`s, and will automatically manage references to each `{{type}}`.
      # See `ReferencePool` for more information.
      protected def pool
        {{type}}ReferencePool.pool
      end
    end

    @references : Hash(String, Prism::ReferenceCounter(T))

    # Creates a new pool with a **clean_callback** that will be called any time an item is orphaned and removed.
    # Use this callback to perform final cleanup operations such as freeing OpenGL resources.
    def initialize(&clean_callback : String, T -> Nil)
      @references = Hash(String, Prism::ReferenceCounter(T)).new
      @clean_callback = clean_callback
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
      @references[key] = Prism::ReferenceCounter(T).new(item)
    end

    # Trashes a reference to an item in the pool.
    # The item will be removed from the pool if there are no more references to it.
    def trash(key : String)
      raise "Item does not exist in the pool: #{key}" unless @references.has_key? key
      reference = @references[key]
      id = reference.trash_one
      if reference.is_orphaned?
        @clean_callback.call(key, id)
        @references.delete(key)
      end
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
