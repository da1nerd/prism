require "../core/vector3f"
require "../core/timer"
require "../core/matrix4f"

module Prism

  class Camera

    Y_AXIS = Vector3f.new(0, 1, 0)

    @mouse_locked = false
    @projection : Matrix4f

    getter pos, forward, up
    setter pos, forward, up

    def initialize(fov : Float32, aspect : Float32, z_near : Float32, z_far : Float32)
      @pos = Vector3f.new(0,0,0)
      @forward = Vector3f.new(0,0,1)
      @up = Vector3f.new(0,1,0)
      @projection = Matrix4f.new().init_perspective(fov, aspect, z_near, z_far)
    end

    def get_view_projection : Matrix4f
      camera_rotation = Matrix4f.new.init_rotation(@forward, @up)
      camera_translation = Matrix4f.new.init_translation(-@pos.x, -@pos.y, -@pos.z)

      @projection * (camera_rotation * camera_translation)
    end

    def input(input : Input)
      center_position = input.get_center
      sensitivity = 0.5f32
      delta = Timer.get_delta.to_f32

      mov_amt = 10 * delta

      # un-lock the cursor
      if input.get_key(Input::KEY_ESCAPE)
        input.set_cursor(true)
        @mouse_locked = false
      end

      # move
      if input.get_key(Input::KEY_W)
        move(forward, mov_amt)
      end
      if input.get_key(Input::KEY_S)
        move(forward, -mov_amt)
      end
      if input.get_key(Input::KEY_A)
        move(left, mov_amt)
      end
      if input.get_key(Input::KEY_D)
        move(right, mov_amt)
      end

      # rotate
      if @mouse_locked
        delta_pos = input.get_mouse_position - center_position

        rot_y = delta_pos.x != 0
        rot_x = delta_pos.y != 0

        if rot_y
          rotate_y(delta_pos.x * sensitivity)
        end
        if rot_x
          rotate_x(delta_pos.y * sensitivity)
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

    # moves the camera
    def move(direction : Vector3f, amount : Float32)
      @pos = @pos + direction * amount # TODO: double check operator logic in Vector3f
    end

    # rotates around the y axis
    def rotate_y(angle : Float32)
      h_axis = Y_AXIS.cross(@forward).normalized
      @forward = @forward.rotate(angle, Y_AXIS).normalized
      @up = @forward.cross(h_axis).normalized
    end

    # rotates around the x axis
    def rotate_x(angle : Float32)
      h_axis = Y_AXIS.cross(@forward).normalized
      @forward = @forward.rotate(angle, h_axis).normalized
      @up = @forward.cross(h_axis).normalized
    end

    # returns the left direction
    def left : Vector3f
      return @forward.cross(@up).normalized
    end

    # returns the right direction
    def right : Vector3f
      return @up.cross(@forward).normalized
    end

  end

end
