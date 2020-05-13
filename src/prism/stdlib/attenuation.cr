module Prism
  # Defines the gradual diminishing in strength of something
  # In other words, how quickly something fades off. This is particularly useful for point lights.
  #
  # The attenuation equation is
  # ```
  # 1 / (constant + linear * x + exponent * x ^ 2)
  # ```
  # The easiest way to understand how to configure attenuation will be to graph it
  # with something like https://www.desmos.com/calculator
  #
  # This just a wrapper around a vector so we can document the different attenuation components.
  class Attenuation < Maths::Vector3f
    def initialize(constant : Float32, linear : Float32, exponent : Float32)
      super
    end

    # Controls the maximum intensity of light.
    # A large value greatly reduces the intensity.
    # A value of 1 or below produces the maximum intensity
    def constant : Float32
      self.x
    end

    # Controls how quickly the intensity at the center of the light dissipates.
    # A large value causes the light to dissipate very quickly.
    def linear : Float32
      self.y
    end

    # Controls how far the light reaches.
    # A very large value causes the light to have a short reach.
    def exponent : Float32
      self.z
    end
  end
end
