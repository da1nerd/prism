require "../core/vector3f"
require "../core/timer"
require "../core/matrix4f"
require "./game_component"

module Prism

  class Camera < GameComponent

    Y_AXIS = Vector3f.new(0, 1, 0)

    @mouse_locked = false
    @projection : Matrix4f

    def initialize(fov : Float32, aspect : Float32, z_near : Float32, z_far : Float32)
      @projection = Matrix4f.new().init_perspective(fov, aspect, z_near, z_far)
    end

    def get_view_projection : Matrix4f
      camera_rotation = self.transform.rot.to_rotation_matrix
      camera_translation = Matrix4f.new.init_translation(-self.transform.pos.x, -self.transform.pos.y, -self.transform.pos.z)

      @projection * (camera_rotation * camera_translation)
    end

    def add_to_rendering_engine(rendering_engine : RenderingEngine)
      rendering_engine.add_camera(self)
    end

    def input(delta : Float32, input : Input)
      center_position = input.get_center
      sensitivity = -0.5f32

      mov_amt = 10.0f32 * delta

      # un-lock the cursor
      if input.get_key(Input::KEY_ESCAPE)
        input.set_cursor(true)
        @mouse_locked = false
      end

      # move
      if input.get_key(Input::KEY_W)
        move(self.transform.rot.forward, mov_amt)
      end
      if input.get_key(Input::KEY_S)
        move(self.transform.rot.forward, -mov_amt)
      end
      if input.get_key(Input::KEY_A)
        move(self.transform.rot.left, mov_amt)
      end
      if input.get_key(Input::KEY_D)
        move(self.transform.rot.right, mov_amt)
      end

      # rotate
      if @mouse_locked
        delta_pos = input.get_mouse_position - center_position

        rot_y = delta_pos.x != 0
        rot_x = delta_pos.y != 0

        if rot_y
          self.transform.rot = self.transform.rot * Quaternion.new().init_rotation(Y_AXIS, Prism.to_rad(delta_pos.x * sensitivity)).normalize
        end
        if rot_x
          self.transform.rot = self.transform.rot * Quaternion.new().init_rotation(self.transform.rot.right, Prism.to_rad(delta_pos.y * sensitivity)).normalize
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
      self.transform.pos = self.transform.pos + direction * amount
    end

  end

end
