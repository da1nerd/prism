require "../src/prism"
require "./position_mask.cr"

# Represents a player in the game
class Player < GameObject
    MOUSE_SENSITIVITY = 0.4375f32
    MOVEMENT_SPEED = 5f32
    DEFAULT_HEIGHT = 0.5f32

    def initialize(position : Vector2f, height : Float32 = DEFAULT_HEIGHT)
        super()
        @look = FreeLook.new(MOUSE_SENSITIVITY)
        @move = FreeMove.new(MOVEMENT_SPEED)
        # TODO: make better way to get window dimensions
        @cam = Camera.new(Prism.to_rad(70.0f32), 800f32/600f32, 0.01f32, 1000.0f32)
        @position_mask = PositionMask.new(Vector3f.new(1f32, 0f32, 1f32))

        camera = GameObject.new().add_component(@look).add_component(@move).add_component(@cam)
        camera.add_component(@position_mask)

        self.add_object(camera)
        self.transform.pos = Vector3f.new(position.x, height, position.y)
    end
end