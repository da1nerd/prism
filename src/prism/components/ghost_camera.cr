require "../core/game_object"

module Prism

    class GhostCamera < GameObject
        def initialize
            super

            cam = Camera.new(Prism::Angle.from_degrees(70.0f32), 800f32/600f32, 0.01f32, 1000.0f32)
            look = FreeLook.new(0.1375f32)
            move = FreeMove.new(4f32)

            add_component(cam)
            add_component(look)
            add_component(move)
            transform.pos.y = 1f32
        end
    end

end