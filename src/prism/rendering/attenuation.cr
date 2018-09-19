module Prism

  class Attenuation

    getter constant, linear, exponent
    setter constant, linear, exponent

    def initialize(@constant : Float32, @linear : Float32, @exponent : Float32)
    end

  end
end
