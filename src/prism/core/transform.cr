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
      translation_matrix = Matrix4f.new
      translation_matrix.init_translation(@pos.x, @pos.y, @pos.z)

      rotation_matrix = @rot.to_rotation_matrix

      scale_matrix = Matrix4f.new
      scale_matrix.init_scale(@scale.x, @scale.y, @scale.z)

      return translation_matrix * (rotation_matrix * scale_matrix)
    end

  end

end
