require "../rendering/shader"
require "../light"

module Prism
  # Represents an ambient light source.
  class AmbientLight < Light
    include Shader::Serializable
    getter color

    @[Shader::Field(key: "R_ambient")]
    @color : Vector3f

    def initialize
      initialize(Vector3f.new(0.1, 0.1, 0.1))
    end

    def initialize(@color : Vector3f)
      shader_path = File.join(File.dirname(PROGRAM_NAME), "/res/shaders/", "forward-ambient")
      self.shader = Shader.new(shader_path)
    end
  end
end
