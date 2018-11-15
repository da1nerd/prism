require "./obstacle.cr"

# Represents a wall in the map
class Wall
    include Obstacle

    getter position, size

    def initialize(@position : Vector3f, @size : Vector3f)
    end
end