module Prism
  # Represents a reference pool singleton.
  # This pools instance of objects and keeps track of references to them.
  # The pool auto cleans itself once a resource loses all of it's references.
  class ReferencePool(T)
    @references : Hash(String, Reference(T))

    # @test : Hash(String, Reference(String))

    def initialize
      @references = Hash(String, Reference(T)).new
    end

    # Checks of the pool contains the resource
    def has_key?(key : String) : Bool
      @references.has_key? key
    end

    # Retrieves a resource from the pool.
    # This will increment the reference counter.
    def use(key) : T
      raise "Resource does not exist: #{key}" unless @references.has_key? key
      @references[key].use
    end

    # Adds a resource to the pool.
    # This will set the reference counter to 0.
    # You must then call `#use` to get your first reference.
    # WARNING: do not use the *resource* you passed in without calling `#use` or you will mess up the reference counter.
    def add(key : String, resource : T)
      raise "Duplicate resource key: #{key}" if @references.has_key? key
      @references[key] = Reference(T).new(resource)
    end

    # Trashes a reference to a resource in the pool.
    # The resource will be removed from the pool after there are no more references.
    def trash(key : String)
      raise "Resource does not exist: #{key}" unless @references.has_key? key
      reference = @references[key]
      reference.trash_one
      @references.delete(key) if reference.is_orphaned?
    end

    # Returns the number of remaining references to the resource
    protected def reference_count(key : String) : Int32
      raise "Resource does not exist: #{key}" unless @references.has_key? key
      @references[key].reference_count
    end
  end
end
