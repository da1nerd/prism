require "../src/prism"

# Locks the position to a specific value
class PositionLock < GameComponent

    def initialize(@mask : Vector3f)
    end

    def update(delta : Float32)
        self.transform.pos += @mask
    end
end