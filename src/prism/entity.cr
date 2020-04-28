require "crash"
require "./moveable.cr"

module Prism
  # Represents an object within the scene graph.
  # The screen graph is composed of a tree of `Entity`s.
  class Entity < Crash::Entity
    def initialize
      super()
      add Transform.new
    end
  end
end
