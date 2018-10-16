require "lib_gl"
require "./reference_counter.cr"

module Prism
  # Manages the state of a single bitmap.
  #
  # Keeps track of references to a single bitmap
  class BitmapResource < ReferenceCounter
  end
end
