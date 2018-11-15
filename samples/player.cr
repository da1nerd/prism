require "../src/prism"
require "./position_mask.cr"
require "./position_lock.cr"
require "./collide_move.cr"
require "./collision_detector.cr"

# Represents a player in the game
class Player < GameObject
    MOUSE_SENSITIVITY = 0.4375f32
    MOVEMENT_SPEED = 5f32
    DEFAULT_HEIGHT = 0.4375f32
    PLAYER_SIZE = 0.2f32

    def initialize(position : Vector2f, detector : CollisionDetector, height : Float32 = DEFAULT_HEIGHT)
        super()
        @look = FreeLook.new(MOUSE_SENSITIVITY)
        @move = CollideMove.new(MOVEMENT_SPEED, detector)
        # TODO: make better way to get window dimensions
        @cam = Camera.new(Prism.to_rad(70.0f32), 800f32/600f32, 0.01f32, 1000.0f32)
        @position_mask = PositionMask.new(Vector3f.new(1f32, 0f32, 1f32))
        @position_lock = PositionLock.new(Vector3f.new(0, height, 0))

        self.add_component(@look)
        self.add_component(@cam)
        self.add_component(@move)

        self.add_component(@position_mask)
        self.add_component(@position_lock)

        self.transform.pos = Vector3f.new(position.x, height, position.y)
    end
end