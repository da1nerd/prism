module Prism
  # A reference counter.
  # This counts the number of references to an object.
  # To properly use the reference you must initialize it with an object to be reference.
  # Then you must only retrives copies of the object with the `#use` method.
  # TODO: rename this to ReferenceCounter
  class Reference(T)
    @count : Int32
    @resource : T

    # Creates a new referenced resource.
    # The reference counter will remain at 0 until use call `#use`
    def initialize(@resource : T)
      @count = 0
    end

    # Uses a new reference of this resource
    def use : T
      @count += 1
      @resource
    end

    # Trashes a single reference to the resource.
    def trash_one
      raise "You cannot decrement the counter below 0" if @count == 0
      @count -= 1
    end

    # Checks if this reference is orphaned (no references).
    # If this is true you should perform some clean up operations so that the resource can be garbage collected.
    def is_orphaned? : Bool
      @count <= 0
    end

    # Returns the number of references to this resource
    protected def reference_count
      @count
    end
  end
end
