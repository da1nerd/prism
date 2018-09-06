require "./vector3f"
require "matrix"
require "./matrix4f"

module Prism

  class Transform

    @translation : Vector3f

    getter translation
    setter translation

    def initialize()
      @translation = Vector3f.new(0, 0, 0)
    end

    # additional setter in case I don't want to create a vector before hand.
    def translation(x : Float32, y : Float32 , z : Float32)
      @translation = Vector3f.new(x, y, z)
    end

    def get_transformation : Matrix4f
      translationMatrix = Matrix4f.new
      translationMatrix.init_translation(@translation.x, @translation.y, @translation.z)
      return translationMatrix
    end

  end

end
