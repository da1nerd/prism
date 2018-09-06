require "matrix"

module Prism

  # TODO: port another matrix class to here
  class Matrix4f

    getter m

    @m : Matrix(Float32)

    def initialize
      @m = Matrix(Float32).new(4, 4)
    end

    def initialize(matrix : Matrix(Float32))
      dimensions = matrix.dimensions;
      raise Matrix::DimensionMismatch.new unless dimensions[0] == 4 && dimensions[1] == 4
      @m = matrix
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

    def init_scale( x : Float32, y : Float32, z : Float32)
      @m = Matrix(Float32).new(4, 4) do |i, r, c|
        r == c ? 1f32 : 0f32
      end
      @m.[]=(0, 0, x);
      @m.[]=(1, 1, y);
      @m.[]=(2, 2, z);
    end

    def init_rotation( x : Float32, y : Float32, z : Float32)
      rx = Matrix(Float32).new(4, 4) do |i, r, c|
        r == c ? 1f32 : 0f32
      end
      ry = Matrix(Float32).new(4, 4) do |i, r, c|
        r == c ? 1f32 : 0f32
      end
      rz = Matrix(Float32).new(4, 4) do |i, r, c|
        r == c ? 1f32 : 0f32
      end

      xrad = x / 180.0f32 * Math::PI
      yrad = y / 180.0f32 * Math::PI
      zrad = z / 180.0f32 * Math::PI

      rz.[]=(0, 0, Math.cos(zrad)); rz.[]=(0, 1, -Math.sin(zrad))
      rz.[]=(1, 0, Math.sin(zrad)); rz.[]=(1, 1, Math.cos(zrad))

      rx.[]=(1, 1, Math.cos(xrad)); rx.[]=(1, 2, -Math.sin(xrad));
      rx.[]=(2, 1, Math.sin(xrad)); rx.[]=(2, 2, Math.cos(xrad));

      ry.[]=(0, 0, Math.cos(yrad)); ry.[]=(0, 2, -Math.sin(yrad));
      ry.[]=(2, 0, Math.sin(yrad)); ry.[]=(2, 2, Math.cos(yrad));

      @m = rz * ry * rz

    end

    def *(other : Matrix4f)
      result = @m * other.m
      return Matrix4f.new(result)
    end

  end

end
