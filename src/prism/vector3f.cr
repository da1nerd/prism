require "./math"
require "./quanternion"

module Prism

  class Vector3f

    getter x, y, z
    # setter z, y, z

    def initialize(@x : Float32, @y : Float32, @z : Float32)
    end

    # Returns a copy of the vector
    def clone
      return Vector3f.new(@x, @y, @z)
    end

    # Returns the length the vector (pythagorean theorem)
    def length : Float32
      return Math.sqrt(@x*@x + @y*@y + @z*@z)
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
    def normalize
      length = length()
      if length > 0
        @x /= length
        @y /= length
        @z /= length
      end
    end

    # Rotates the vector by some angle
    def rotate(angle : Float32, axis : Vector3f) : Vector3f
      sin_angle = Math.sin(Prism.to_rad(-angle))
      cos_angle = Math.cos(Prism.to_rad(-angle))

      x_rotation = self.cross(axis * sin_angle) # rotation on local X
      z_rotation = self * cos_angle # roate on local Z
      y_rotation = axis * self.dot(axis * (1 - cos_angle)) # rotation on local Y

      rotation = x_rotation + z_rotation + y_rotation
      @x = rotation.x
      @y = rotation.y
      @z = rotation.z

      return self
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

    def to_string
      return "(#{@x}, #{@y}, #{@z})"
    end

    def abs : Vector3f
      return Vector3f.new(@x.abs, @y.abs, @z.abs)
    end

  end

end
