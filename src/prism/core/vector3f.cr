require "./math"
require "./quanternion"

module Prism
  class Vector3f
    getter x, y, z

    def initialize(@x : Float32, @y : Float32, @z : Float32)
    end

    def initialize(vector : Vector3f)
      initialize(vector.x, vector.y, vector.z)
    end

    # Returns a copy of the vector
    def clone
      return Vector3f.new(@x, @y, @z)
    end

    # Returns the length the vector (pythagorean theorem)
    def length : Float32
      return Math.sqrt(@x*@x + @y*@y + @z*@z)
    end

    # Returns the maximum component size
    def max
      return Math.max(@x, Math.max(@y, @z))
    end

    # Returns the dot product of the vectors
    def dot(r : Vector3f) : Float32
      return @x * r.x + @y * r.y + @z * r.z
    end

    # Returns the cross product of the vectors
    def cross(other : Vector3f) : Vector3f
      Vector3f.new(
        @y*other.z - @z*other.y,
        @z*other.x - @x*other.z,
        @x*other.y - @y*other.x
      )
    end

    # Normalizes this vector to a length of 1
    def normalized
      length = length()
      return Vector3f.new(@x / length, @y / length, @z / length)
    end

    # Rotates the vector by some angle
    def rotate(axis : Vector3f, angle : Float32) : Vector3f
      return self.rotate(Quaternion.new.init_rotation(axis, angle))
    end

    def rotate(rotation : Quaternion) : Vector3f
      conjugate = rotation.conjugate
      w = (rotation * self) * conjugate
      return Vector3f.new(w.x.to_f32, w.y.to_f32, w.z.to_f32)
    end

    # Linear interpolation
    def lerp(dest : Vector3f, lerp_factor : Float32) : Vector3f
      return ((dest - self) * lerp_factor) + self
    end

    # Adds two vectors
    def +(r : Vector3f) : Vector3f
      return Vector3f.new(@x + r.x, @y + r.y, @z + r.z)
    end

    # Adds a scalar value to the vector
    def +(r : Float32) : Vector3f
      return Vector3f.new(@x + r, @y + r, @z + r)
    end

    # Subtracts two vectors
    def -(r : Vector3f) : Vector3f
      return Vector3f.new(@x - r.x, @y - r.y, @z - r.z)
    end

    # Subtracts a scalar value from the vector
    def -(r : Float32) : Vector3f
      return Vector3f.new(@x - r, @y - r, @z - r)
    end

    # Multiplies two vectors
    def *(r : Vector3f) : Vector3f
      return Vector3f.new(@x * r.x, @y * r.y, @z * r.z)
    end

    # Multiplies the vector with a scalar
    def *(r : Float32) : Vector3f
      return Vector3f.new(@x * r, @y * r, @z * r)
    end

    # Divides two vectors
    def /(r : Vector3f) : Vector3f
      return Vector3f.new(@x / r.x, @y / r.y, @z / r.z)
    end

    # Divides the vector by a scalar
    def /(r : Float32) : Vector3f
      return Vector3f.new(@x / r, @y / r, @z / r)
    end

    def ==(r : Vector3f) : Bool
      return @x == r.x && @y == r.y && @z == r.z
    end

    def to_string
      return "(#{@x}, #{@y}, #{@z})"
    end

    def xy : Vector2f
      Vector2f.new(@x, @y)
    end

    def yz : Vector2f
      Vector2f.new(@y, @z)
    end

    def zx : Vector2f
      Vector2f.new(@z, @x)
    end

    def yx : Vector2f
      Vector2f.new(@y, @x)
    end

    def zy : Vector2f
      Vector2f.new(@z, @y)
    end

    def xz : Vector2f
      Vector2f.new(@x, @z)
    end

    def abs : Vector3f
      return Vector3f.new(@x.abs, @y.abs, @z.abs)
    end

    def set(@x : Float32, @y : Float32, @z : Float32)
      self
    end

    def set(r : Vector3f)
      self.set(r.x, r.y, r.z)
      self
    end
  end
end
