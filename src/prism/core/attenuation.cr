module Prism::Core
  # Defines the gradual diminishing in strength of something
  # In other words, how quickly something fades off. This is particularly useful for point lights.
  #
  # The attenuation equation is
  # ```
  # 1 / (constant + linear * x + exponent * x^2)
  # ```
  # The easiest way to understand how to configure attenuation will be to graph it
  # with something like https://www.desmos.com/calculator
  class Attenuation < VMath::Vector3f
    include Shader::Serializable

    def initialize(constant : Float32, linear : Float32, exponent : Float32)
      super
    end

    # Controls the maximum intensity of light.
    # A large value greatly reduces the intensity.
    # A value of 1 or below produces the maximum intensity
    @[Shader::Field(key: "constant")]
    def constant : Float32
      self.x
    end

    # Controlls how quickly the intensity at the center of the light dissipates.
    # A lage value causes the light to dissipate very quickly.
    @[Shader::Field(key: "linear")]
    def linear : Float32
      self.y
    end

    # Controls how far the light reaches.
    # A very large value causes the light to have a short reach.
    @[Shader::Field(key: "exponent")]
    def exponent : Float32
      self.z
    end
  end
end
