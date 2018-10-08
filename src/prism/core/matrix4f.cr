require "matrix"
require "./math"

module Prism

  # TODO: port another matrix class to here
  class Matrix4f

    @m : Matrix(Float32)

    def initialize
      @m = Matrix(Float32).new(4, 4)
    end

    def initialize(matrix : Matrix(Float32))
      dimensions = matrix.dimensions;
      raise Matrix::DimensionMismatch.new unless dimensions[0] == 4 && dimensions[1] == 4
      @m = matrix
    end

    def m
      return @m.clone
    end

    def as_array
      @m.to_a
    end

    def init_identity
      @m = Matrix(Float32).new(4, 4) do |i, r, c|
        r == c ? 1f32 : 0f32
      end
      self
    end

    def init_perspective(fov : Float32, aspect_ratio : Float32, z_near : Float32, z_far : Float32)
      tan_half_fov = Math.tan(fov / 2) # center of window
      z_range = z_near - z_far

      # start with identity matrix
      @m = Matrix(Float32).new(4, 4) do |i, r, c|
        r == c ? 1f32 : 0f32
      end
      @m.[]=(0, 0, 1.0f32 / (tan_half_fov * aspect_ratio))
      @m.[]=(1, 1, 1.0f32 / tan_half_fov)
      @m.[]=(2, 2, (-z_near - z_far) / z_range);  @m.[]=(2, 3, 2.0f32 * z_far * z_near / z_range)
      @m.[]=(3, 2, 1.0f32);                       @m.[]=(3, 3, 0.0f32)
      self
    end

    def init_orthographic(left : Float32, right : Float32, bottom : Float32, top : Float32, near : Float32, far : Float32) : Matrix4f
      width = right - left
      height = top - bottom
      depth = far - near

      # start with identity matrix
      @m = Matrix(Float32).new(4, 4) do |i, r, c|
        r == c ? 1f32 : 0f32
      end

      @m.[]=(0, 0, 2/width); @m.[]=(0, 3, -(right + left)/width)
      @m.[]=(1, 1, 2/height); @m.[]=(1, 3, -(top + bottom)/height)
      @m.[]=(2, 2, -2/depth); @m.[]=(2, 3, -(far + near)/depth)

      self
    end

    def init_rotation(forward : Vector3f, up : Vector3f)
      f = forward.normalized;
      r = up.normalized.cross(f);
      u = f.cross(r)

      return self.init_rotation(f, u, r)
    end

    def init_rotation(forward : Vector3f, up : Vector3f, right : Vector3f)
      f = forward
      r = right
      u = up

      # start with identity matrix
      @m = Matrix(Float32).new(4, 4) do |i, r, c|
        r == c ? 1f32 : 0f32
      end

      @m.[]=(0, 0, r.x); @m.[]=(0, 1, r.y); @m.[]=(0, 2, r.z);
      @m.[]=(1, 0, u.x); @m.[]=(1, 1, u.y); @m.[]=(1, 2, u.z);
      @m.[]=(2, 0, f.x); @m.[]=(2, 1, f.y); @m.[]=(2, 2, f.z);
      self
    end

    # Turns the matrix into a translation matrix
    def init_translation( x : Float32, y : Float32, z : Float32)
      # start with identity matrix
      @m = Matrix(Float32).new(4, 4) do |i, r, c|
        r == c ? 1f32 : 0f32
      end
      @m.[]=(0, 3, x)
      @m.[]=(1, 3, y)
      @m.[]=(2, 3, z)
      self
    end

    def init_scale( x : Float32, y : Float32, z : Float32)
      # start with identity matrix
      @m = Matrix(Float32).new(4, 4) do |i, r, c|
        r == c ? 1f32 : 0f32
      end
      @m.[]=(0, 0, x);
      @m.[]=(1, 1, y);
      @m.[]=(2, 2, z);
      self
    end

    def init_rotation( x : Float32, y : Float32, z : Float32)
      # start with identity matricies
      rx = Matrix(Float32).new(4, 4) do |i, r, c|
        r == c ? 1f32 : 0f32
      end
      ry = Matrix(Float32).new(4, 4) do |i, r, c|
        r == c ? 1f32 : 0f32
      end
      rz = Matrix(Float32).new(4, 4) do |i, r, c|
        r == c ? 1f32 : 0f32
      end

      xrad = Prism.to_rad(x)
      yrad = Prism.to_rad(y)
      zrad = Prism.to_rad(z)

      rz.[]=(0, 0, Math.cos(zrad)); rz.[]=(0, 1, -Math.sin(zrad))
      rz.[]=(1, 0, Math.sin(zrad)); rz.[]=(1, 1, Math.cos(zrad))

      rx.[]=(1, 1, Math.cos(xrad)); rx.[]=(1, 2, -Math.sin(xrad));
      rx.[]=(2, 1, Math.sin(xrad)); rx.[]=(2, 2, Math.cos(xrad));

      ry.[]=(0, 0, Math.cos(yrad)); ry.[]=(0, 2, -Math.sin(yrad));
      ry.[]=(2, 0, Math.sin(yrad)); ry.[]=(2, 2, Math.cos(yrad));

      @m = rx * ry * rz
      self
    end

    def transform(r : Vector3f) : Vector3f
      return Vector3f.new(
        @m[0, 0] * r.x + @m[0, 1] * r.y + @m[0, 2] * r.z + @m[0, 3],
        @m[1, 0] * r.x + @m[1, 1] * r.y + @m[1, 2] * r.z + @m[1, 3],
        @m[2, 0] * r.x + @m[2, 1] * r.y + @m[2, 2] * r.z + @m[2, 3]
      )
    end

    def *(other : Matrix4f)
      result = @m * other.m
      return Matrix4f.new(result)
    end

  end

end
