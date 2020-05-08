module Prism
  # Keeps track of references to the class instance
  # DEPRECATED we are migrating to `ReferencePool` instead.
  abstract class ReferenceCounter
    @ref_count : Int32 = 1

    # Adds a reference to the counter
    def add_reference
      @ref_count += 1
    end

    # Removes a reference from the counter
    #
    # Returns `true` if there are no more references
    def remove_reference
      @ref_count -= 1 if @ref_count > 0
      return @ref_count == 0
    end

    # Checks if there are any references of this object
    def has_references? : Bool
      return @ref_count > 0
    end
  end
end
