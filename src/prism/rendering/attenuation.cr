module Prism
    # Defines the gradual diminishing in strength of something
    class Attenuation < Vector3f

        def initialize(constant : Float32, linear : Float32, exponent : Float32)
            super
        end

        def constant : Float32
            self.x
        end

        def linear : Float32
            self.y
        end

        def exponent : Float32
            self.z
        end

    end
end