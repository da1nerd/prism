require "../core/game_object"

module Prism
    module Shapes
        class Box < GameObject
            def initialize(@size : Float32)
                super()
            end
        end

    end
end