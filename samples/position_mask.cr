require "../src/prism"

# Applies a mask to the position.
# This allows you to enable or disable position transformation along an axis.
class PositionMask < GameComponent

    def initialize(@mask : Vector3f)
    end

    def update(delta : Float32)
        self.transform.pos *= @mask
    end
end