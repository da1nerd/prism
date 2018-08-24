module Prism

  class Vector3f

    property x : Float32
    property y : Float32
    property z : Float32

    def initialize(@x : Float32, @y : Float32, @z : Float32)
    end

    # Returns the length the vector (pythagorean theorem)
    def length : Float32
      return Math.sqrt(@x^2 + @y^2 + @z^2)
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

      return new Vector3f.new(x, y, z)
    end

    # Normalizes this vector to a length of 1
    def normalize : Vector3f
      length = length()
      @x /= length
      @y /= length
      @z /= length
    end

    # Rotates the vector by some angle
    def rotate(angle) : Vector3f
      return nil
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
