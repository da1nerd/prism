module Prism
  # Defines the gradual diminishing in strength of something
  class Attenuation < Vector3f
    include Uniform::Serializable

    def initialize(constant : Float32, linear : Float32, exponent : Float32)
      super
    end

    @[Uniform::Field(key: "constant")]
    def constant : Float32
      self.x
    end

    @[Uniform::Field(key: "linear")]
    def linear : Float32
      self.y
    end

    @[Uniform::Field(key: "exponent")]
    def exponent : Float32
      self.z
    end
  end
end
