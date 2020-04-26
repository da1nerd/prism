module Prism::Common::Light
  # Represents an ambient light source.
  # This is a special type of light that provides a minimum amount of light to the entire scene.
  # For now you always need to have an ambient light otherwise no other light sources will work.
  # That may be a bug that get's fixed later on.
  # DEPRECATED we'll add ambient lighting in the other lights.
  class AmbientLight < Core::AmbientLight
    getter color

    @[Core::Shader::Field(name: "R_ambient")]
    @color : Vector3f

    def initialize
      initialize(Vector3f.new(0.1, 0.1, 0.1))
    end

    def initialize(@color : Vector3f)
    end
  end
end
