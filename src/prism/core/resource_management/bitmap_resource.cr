require "./reference_counter.cr"

module Prism::Core
  # Manages the state of a single bitmap.
  #
  # Keeps track of references to a single bitmap
  class BitmapResource < ReferenceCounter
  end
end
