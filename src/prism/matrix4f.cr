require "matrix"

module Prism

  # TODO: port another matrix class to here
  class Matrix4f

    @m : Matrix(Float32)

    def initialize
      @m = Matrix(Float32).new(4, 4)
    end

    def as_array
      @m.to_a
    end

    # Turns the matrix into a translation matrix
    def init_translation( x : Float32, y : Float32, z : Float32)
      @m = Matrix(Float32).new(4, 4) do |i, r, c|
        r == c ? 1f32 : 0f32
      end
      @m.[]=(0, 3, x);
      @m.[]=(1, 3, y);
      @m.[]=(2, 3, z);
    end

  end

end
