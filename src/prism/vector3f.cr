require "./math"
require "./quanternion"

module Prism

  class Vector3f

    property x : Float32
    property y : Float32
    property z : Float32

    def initialize(@x : Float32, @y : Float32, @z : Float32)
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
    def cross(r : Vector3f) : Vector3f
      x = @y * r.z - z * r.y
      y = @z * r.x - x * r.z
      z = @x * r.y - y * r.x

      return Vector3f.new(x, y, z)
    end

    # Normalizes this vector to a length of 1
    def normalize
      length = length()
      @x /= length
      @y /= length
      @z /= length
    end

    # Rotates the vector by some angle
    def rotate(angle : Float32, axis : Vector3f) : Vector3f
      sin_half_angle = Math.sin(Prism.to_rad(angle / 2))
      cos_half_angle = Math.cos(Prism.to_rad(angle / 2))

      r_x = axis.x * sin_half_angle
      r_y = axis.y * sin_half_angle
      r_z = axis.z * sin_half_angle
      r_w = cos_half_angle

      rotation = Quaternion.new(r_x.to_f, r_y.to_f, r_z.to_f, r_w.to_f)
      conjugate = rotation.conjugate

      w = rotation * self * conjugate

      @x = w.x.to_f32
      @y = w.y.to_f32
      @z = w.z.to_f32

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

  end

end
