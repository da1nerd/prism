module Prism::Common::Light
  # Represents an ambient light source.
  class AmbientLight < Core::AmbientLight
    SHADER_PATH = File.join(File.dirname(PROGRAM_NAME), "/res/shaders/", "forward-ambient")
    include Core::Shader::Serializable
    getter color

    @[Core::Shader::Field(key: "R_ambient")]
    @color : Vector3f

    def initialize
      initialize(Vector3f.new(0.1, 0.1, 0.1))
    end

    def initialize(@color : Vector3f)
      super(Core::Shader.new(SHADER_PATH))
    end
  end
end
