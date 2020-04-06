require "../core/vector3f"
require "../rendering/shader"

module Prism
  # Fundamental light component
  class BaseLight < Light
    include Shader::Serializable

    @[Shader::Field(key: "color")]
    @color : Vector3f

    @[Shader::Field(key: "intensity")]
    @intensity : Float32

    property color, intensity

    def initialize(@color : Vector3f, @intensity : Float32)
    end
  end
end
