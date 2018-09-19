require "./base_light"
require "../core/vector3f"

module Prism

  class DirectionalLight

    getter base, direction
    setter base

    def initialize(@base : BaseLight, @direction : Vector3f)
      @direction = @direction.normalized
    end

    def direction=(@direction : Vector3f)
      @direction = @direction.normalized
    end

  end

end
