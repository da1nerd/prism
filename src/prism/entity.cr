require "crash"

module Prism
  # An entity is a collection of components
  # All entities start with a default `Transform` `Crash::Component`.
  class Entity < Crash::Entity
    def initialize
      super()
      add Transform.new
    end
  end
end
