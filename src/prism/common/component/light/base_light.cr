module Prism::Common::Light
  # A pseudo light object that provides some of the basic light properties.
  # This light source is at a location within the scene.
  class BaseLight
    include Core::Shader::Serializable

    @[Core::Shader::Field(key: "color")]
    @color : Vector3f

    @[Core::Shader::Field(key: "intensity")]
    @intensity : Float32

    property color, intensity

    def initialize(@color : Vector3f, @intensity : Float32)
    end
  end
end
