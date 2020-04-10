module Prism::VMath
  # Represents an angle value in the engine.
  struct Angle
    @angle : Float32

    def initialize(@angle)
    end

    # Returns the angle in radians
    def radians
      @angle
    end

    # Create an angle from *degrees*
    #
    def self.from_degrees(degrees) : Angle
      Angle.new(degrees / 180f32 * Math::PI)
    end

    # Creates an angle from *radians*
    def self.from_radians(radians) : Angle
      Angle.new(radians.to_f32)
    end
  end
end
