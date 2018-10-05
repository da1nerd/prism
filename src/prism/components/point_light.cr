require "./base_light"

module Prism

  class PointLight < BaseLight

    getter position, atten, range, constant, linear, exponent
    setter position, atten, range, constant, linear, exponent

    def initialize(color : Vector3f, intensity : Float32, @constant : Float32, @linear : Float32, @exponent : Float32, @position : Vector3f, @range : Float32)
      super(color, intensity)

      self.shader = ForwardPoint.instance
    end

  end

end
