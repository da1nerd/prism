require "./game_component.cr"

module Prism
  class FreeLook < GameComponent
    Y_AXIS = Vector3f.new(0, 1, 0)
    @mouse_locked = false

    getter mouse_locked

    def initialize(sensitivity : Float32)
      initialize(sensitivity, Input::KEY_ESCAPE)
    end

    def initialize(@sensitivity : Float32, @unlock_mouse_key : Int32)
    end

    def input(delta : Float32, input : Input)
      center_position = input.get_center

      # un-lock the cursor
      if input.get_key(@unlock_mouse_key)
        input.set_cursor(true)
        @mouse_locked = false
      end

      # rotate
      if @mouse_locked
        delta_pos = input.get_mouse_position - center_position

        rot_y = delta_pos.x != 0
        rot_x = delta_pos.y != 0

        if rot_y
          self.transform.rotate(Y_AXIS, Prism.to_rad(delta_pos.x * @sensitivity))
        end
        if rot_x
          self.transform.rotate(self.transform.rot.right, Prism.to_rad(delta_pos.y * @sensitivity))
        end

        if rot_y || rot_x
          input.set_mouse_position(center_position)
        end
      end

      # lock the cursor
      if input.get_mouse_down(0)
        input.set_mouse_position(center_position)
        input.set_cursor(false)
        @mouse_locked = true
      end
    end
  end
end
