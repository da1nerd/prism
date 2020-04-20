module Prism::EntitySystem::Components
  class Position < Component
    def initialize(@x : Float32, @y : Float32, @rotation : Float32)
    end
  end
end
