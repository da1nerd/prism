module Prism
  struct ColorUInt8
    property red, green, blue, alpha

    def initialize(red : UInt8, green : UInt8, blue : UInt8)
      initialize(red, green, blue, 1)
    end

    def initialize(@red : UInt8, @green : UInt8, @blue : UInt8, @alpha : UInt8)
    end

    # Checks if the color is black
    def black?
      return red == 0 && green == 0 && blue == 0
    end

    # Checks if the color is white
    def white?
      return red == 255 && green == 255 && blue == 255
    end

    # Checks if the color has transparency
    def transparent?
      return @alpha > 0
    end

    def to_s
      "0x#{red.to_s(16)}#{green.to_s(16)}#{blue.to_s(16)}#{alpha.to_s(16)}"
    end
  end
end
