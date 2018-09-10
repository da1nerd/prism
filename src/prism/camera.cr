require "./vector3f"
require "./timer"

module Prism

  class Camera

    Y_AXIS = Vector3f.new(0, 1, 0)

    getter pos, forward, up
    setter pos, forward, up

    def initialize
      initialize(Vector3f.new(0, 0, 0), Vector3f.new(0, 0, 1), Vector3f.new(0, 1, 0))
    end

    def initialize(@pos : Vector3f, @forward : Vector3f, @up : Vector3f)
      @up.normalize
      @forward.normalize
    end

    def input(input : Input)
      delta = Timer.get_delta

      return unless delta

      mov_amt = 10 * delta
      rot_amt = 100 * delta

      # move
      # if input.get_key(Input::KEY_W)
      #   move(forward, mov_amt)
      # end
      # if input.get_key(Input::KEY_S)
      #   move(forward, -mov_amt)
      # end
      # if input.get_key(Input::KEY_A)
      #   move(left, mov_amt)
      # end
      # if input.get_key(Input::KEY_D)
      #   move(right, mov_amt)
      # end

      # TODO: the special keys and keyboard keys do not have unique values.
      # e..g KEY_D has the same code as KEY_LEFT

      # TODO: the rotation is broken. Need to fix quaternion logic
      # rotate
      if input.get_key(Input::KEY_UP)
        rotate_x(-rot_amt)
      end
      if input.get_key(Input::KEY_DOWN)
        rotate_x(rot_amt)
      end
      if input.get_key(Input::KEY_LEFT)
        rotate_y(-rot_amt)
      end
      if input.get_key(Input::KEY_RIGHT)
        rotate_y(rot_amt)
      end
    end

    # moves the camera
    def move(direction : Vector3f, amount : Float32)
      @pos = @pos + direction * amount # TODO: double check operator logic in Vector3f
    end

    # rotates around the y axis
    def rotate_y(angle : Float32)
      h_axis = Y_AXIS.cross(@forward)
      h_axis.normalize

      @forward.rotate(angle, Y_AXIS)
      @forward.normalize

      @up = @forward.cross(h_axis)
      @up.normalize
    end

    # rotates around the x axis
    def rotate_x(angle : Float32)
      h_axis = Y_AXIS.cross(@forward) # TODO: confirm cross product logic
      h_axis.normalize

      @forward.rotate(angle, h_axis)
      @forward.normalize

      @up = @forward.cross(h_axis)
      @up.normalize
    end

    # returns the left direction
    def left : Vector3f
      l = @forward.cross(@up)
      l.normalize
      return l
    end

    # returns the right direction
    def right : Vector3f
      r = @up.cross(@forward)
      r.normalize
      return r
    end

  end

end
