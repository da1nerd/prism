require "./vector3f"
require "matrix"
require "./matrix4f"

module Prism

  class Transform

    @parent : Transform?
    @parent_matrix : Matrix4f

    @pos : Vector3f
    @rot : Quaternion
    @scale : Vector3f

    @old_pos : Vector3f?
    @old_rot : Quaternion?
    @old_scale : Vector3f?

    getter pos, rot, scale
    setter pos, rot, scale, parent

    def initialize()
      @pos = Vector3f.new(0.0f32, 0.0f32, 0.0f32)
      @rot = Quaternion.new(0.0f64, 0.0f64, 0.0f64, 1.0f64)
      @scale = Vector3f.new(1.0f32, 1.0f32, 1.0f32)
      @parent_matrix = Matrix4f.new().init_identity
    end

    def has_changed

      if @old_pos == nil
        @old_pos = Vector3f.new(0f32,0f32,0f32).set(@pos)
        @old_rot = Quaternion.new(0f64, 0f64, 0f64, 0f64).set(@rot)
        @old_scale = Vector3f.new(0f32, 0f32, 0f32).set(@scale)
        return true
      end

      if parent = @parent
        return parent.has_changed
      end

      if @pos == @old_pos
        return true
      end

      if @rot == @old_rot
        return true
      end

      if @scale == @old_scale
        return true
      end

      return false
    end

    def get_transformation : Matrix4f
      translation_matrix = Matrix4f.new().init_translation(@pos.x, @pos.y, @pos.z)
      rotation_matrix = @rot.to_rotation_matrix
      scale_matrix = Matrix4f.new().init_scale(@scale.x, @scale.y, @scale.z)

      if @old_pos != nil
        @old_pos = @pos
        @old_rot = @rot
        @old_scale = @scale
      end

      return self.get_parent_matrix * translation_matrix * rotation_matrix * scale_matrix
    end

    private def get_parent_matrix : Matrix4f
      if parent = @parent
        if parent.has_changed
          @parent_matrix = parent.get_transformation
        end
      end

      return @parent_matrix
    end

  end

end
