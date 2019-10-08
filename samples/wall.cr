require "./obstacle.cr"

# Represents a wall in the map
class Wall
    include Obstacle

    @position : Vector3f
    @size : Vector3f

    def initialize(@position : Vector3f, @size : Vector3f)
    end

    def position : Prism::Vector3f
        @position
    end

    def size : Prism::Vector3f
        @size
    end
end