require "../rendering/shader"

module Prism
  # A pseudo light object that provides some of the basic light properties.
  class BaseLight
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
