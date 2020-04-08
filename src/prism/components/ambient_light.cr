require "../rendering/shader"
require "../light"

module Prism
  # Represents an ambient light source.
  class AmbientLight < Light
    SHADER_PATH = File.join(File.dirname(PROGRAM_NAME), "/res/shaders/", "forward-ambient")
    include Shader::Serializable
    getter color

    @[Shader::Field(key: "R_ambient")]
    @color : Vector3f

    def initialize
      initialize(Vector3f.new(0.1, 0.1, 0.1))
    end

    def initialize(@color : Vector3f)
      super(Shader.new(SHADER_PATH))
    end
  end
end
