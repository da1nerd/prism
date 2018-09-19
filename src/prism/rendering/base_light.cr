require "../core/vector3f"

module Prism

  class BaseLight

    getter color, intensity
    setter color, intensity

    def initialize(@color : Vector3f, @intensity : Float32)
    end

  end

end
