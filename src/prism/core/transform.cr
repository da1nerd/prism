require "./vector3f"
require "matrix"
require "./matrix4f"

module Prism
  # Handles positional transformations
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

    def initialize
      @pos = Vector3f.new(0.0f32, 0.0f32, 0.0f32)
      @rot = Quaternion.new(0.0f64, 0.0f64, 0.0f64, 1.0f64)
      @scale = Vector3f.new(1.0f32, 1.0f32, 1.0f32)
      @parent_matrix = Matrix4f.new.init_identity
    end

    def update
      if @old_pos != nil
        @old_pos = @pos
        @old_rot = @rot
        @old_scale = @scale
      else
        @old_pos = Vector3f.new(0f32, 0f32, 0f32).set(@pos) + 1.0f32
        @old_rot = Quaternion.new(0f64, 0f64, 0f64, 0f64).set(@rot) * 0.5f64
        @old_scale = Vector3f.new(0f32, 0f32, 0f32).set(@scale) + 1.0f32
      end
    end

    def rotate(axis : Vector3f, angle : Float32)
      @rot = (Quaternion.new(axis, angle) * @rot).normalize
    end

    # Rotates to look at the point
    def look_at(point : Vector3f, up : Vector3f)
      @rot = get_look_at_direction(point, up)
    end

    # Creates a transformation to look at a point
    # This is handy for applying some form of lerp'ing.
    def get_look_at_direction(point : Vector3f, up : Vector3f) : Quaternion
      return Quaternion.new(Matrix4f.new.init_rotation((point - @pos).normalized, up))
    end

    # Checks if the transformation higher up the tree has changed
    def has_changed
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

    # Returns the transformation as affected by the parent
    def get_transformation : Matrix4f
      translation_matrix = Matrix4f.new.init_translation(@pos.x, @pos.y, @pos.z)
      rotation_matrix = @rot.to_rotation_matrix
      scale_matrix = Matrix4f.new.init_scale(@scale.x, @scale.y, @scale.z)

      return self.get_parent_matrix * translation_matrix * rotation_matrix * scale_matrix
    end

    # Returns the the position after it has been transformed by it's parent
    def get_transformed_pos : Vector3f
      return self.get_parent_matrix.transform(@pos)
    end

    # Returns the rotation after it has been transformed by it's parent
    def get_transformed_rot : Quaternion
      parent_rotation = Quaternion.new(0f64, 0f64, 0f64, 1f64)

      if parent = @parent
        if parent.has_changed
          parent_rotation = parent.get_transformed_rot
        end
      end

      return parent_rotation * @rot
    end

    # Returns the parent transformation matrix
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
