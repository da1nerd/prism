module Prism
  # Keeps track of references to the class instance
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
      @ref_count -= 1
      return @ref_count == 0
    end
  end
end
