require "./vector3f"
require "matrix"
require "./matrix4f"

module Prism

  class Transform

    @translation : Vector3f
    @rotation : Vector3f

    getter translation
    setter translation
    getter rotation
    setter rotation

    def initialize()
      @translation = Vector3f.new(0, 0, 0)
      @rotation = Vector3f.new(0, 0, 0)
    end

    # additional setter in case I don't want to create a vector before hand.
    def translation(x : Float32, y : Float32 , z : Float32)
      @translation = Vector3f.new(x, y, z)
    end

    def rotation(x : Float32, y : Float32 , z : Float32)
      @rotation = Vector3f.new(x, y, z)
    end

    def get_transformation : Matrix4f
      trans = Matrix4f.new
      trans.init_translation(@translation.x, @translation.y, @translation.z)

      rot = Matrix4f.new
      rot.init_rotation(@rotation.x, @rotation.y, @rotation.z)

      return trans * rot
    end

  end

end
