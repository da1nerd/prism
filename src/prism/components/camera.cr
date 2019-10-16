require "../core/vector3f"
require "../core/matrix4f"
require "./game_component"

module Prism
  class Camera < GameComponent
    @projection : Matrix4f

    # Creates a camera with default values
    def initialize
      field_of_view : Float32 = Angle.from_degrees(65)
      # TODO: get window aspect ratio
      aspect_ratio : Float32 = 1f32 / 1
      initialize(field_of_view, aspect_ratio, 0.01f32, 1000f32)
    end

    def initialize(@fov : Float32, @aspect : Float32, @z_near : Float32, @z_far : Float32)
      @projection = Matrix4f.new.init_perspective(@fov, @aspect, @z_near, @z_far)
    end

    # changes the aspect ratio
    def aspect=(aspect_ratio : Float32)
      @aspect = aspect_ratio
      @projection = Matrix4f.new.init_perspective(@fov, @aspect, @z_near, @z_far)
    end

    def get_view_projection : Matrix4f
      camera_rotation = self.transform.get_transformed_rot.conjugate.to_rotation_matrix
      camera_pos = self.transform.get_transformed_pos * -1
      camera_translation = Matrix4f.new.init_translation(camera_pos.x, camera_pos.y, camera_pos.z)

      @projection * (camera_rotation * camera_translation)
    end

    def add_to_engine(engine : CoreEngine)
      engine.rendering_engine.add_camera(self)
    end
  end
end
