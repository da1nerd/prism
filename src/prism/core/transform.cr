require "./vector3f"
require "matrix"
require "./matrix4f"
require "../rendering/camera"

module Prism

  class Transform

    @pos : Vector3f
    @rot : Quaternion
    @scale : Vector3f

    getter pos, rot, scale
    setter pos, rot, scale

    def initialize()
      @pos = Vector3f.new(0.0f32, 0.0f32, 0.0f32)
      @rot = Quaternion.new(0.0f64, 0.0f64, 0.0f64, 1.0f64)
      @scale = Vector3f.new(1.0f32, 1.0f32, 1.0f32)
    end

    def get_transformation : Matrix4f
      trans = Matrix4f.new
      trans.init_translation(@pos.x, @pos.y, @pos.z)

      rot = @rot.to_rotation_matrix #Matrix4f.new
      #rot.init_rotation(@rot.x, @rot.y, @rot.z)

      scl = Matrix4f.new
      scl.init_scale(@scale.x, @scale.y, @scale.z)

      return trans * (rot * scl)
    end

  end

end
