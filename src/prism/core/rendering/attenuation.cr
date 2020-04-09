module Prism::Core
  # Defines the gradual diminishing in strength of something
  # In other words, how quickly something fades off. This is particularly useful for point lights.
  # 
  class Attenuation < VMath::Vector3f
    include Shader::Serializable

    def initialize(constant : Float32, linear : Float32, exponent : Float32)
      super
    end

    @[Shader::Field(key: "constant")]
    def constant : Float32
      self.x
    end

    @[Shader::Field(key: "linear")]
    def linear : Float32
      self.y
    end

    @[Shader::Field(key: "exponent")]
    def exponent : Float32
      self.z
    end
  end
end
