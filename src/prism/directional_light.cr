require "./base_light"
require "./vector3f"

module Prism

  class DirectionalLight

    getter base, direction
    setter base, direction

    def initialize(@base : BaseLight, @direction : Vector3f)
    end

  end

end
