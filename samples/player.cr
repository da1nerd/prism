require "../src/prism"
require "./position_mask.cr"

class Player < GameObject
    CAMERA_HEIGHT = 0.5f32

    def initialize(position : Vector2f)
        super()
        @look = FreeLook.new(0.5)
        @move = FreeMove.new(10.0)
        @cam = Camera.new(Prism.to_rad(70.0f32), 800f32/600f32, 0.01f32, 1000.0f32)
        @position_mask = PositionMask.new(Vector3f.new(1f32, 0f32, 1f32))

        camera = GameObject.new().add_component(@look).add_component(@move).add_component(@cam)
        camera.add_component(@position_mask)

        self.add_object(camera)
        self.transform.pos = Vector3f.new(position.x, CAMERA_HEIGHT, position.y)
    end
end