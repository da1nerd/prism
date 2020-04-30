module Prism
  # Manages the state of a single bitmap.
  #
  # Keeps track of references to a single bitmap
  class BitmapResource < Prism::ReferenceCounter
  end
end
