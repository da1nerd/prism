require "./math"

module Prism

  class Vector2f

    property x : Float32
    property y : Float32

    def initialize(@x : Float32, @y : Float32)

    end

    # Returns the length the vector (pythagorean theorem)
    def length : Float32
      return Math.sqrt(@x * @x + @y * @y)
    end

    # Returns the dot product of the vectors
    def dot(r : Vectorf2) : Float32
      return @x * r.x + @y * r.y
    end

    # Normalizes this vector to a length of 1
    def normalize : Vector2f
      length = length()
      @x /= length
      @y /= length

      return self
    end

    # Rotates the vector by some angle
    def rotate(angle : Float32) : Vector2f
      rad : Float32 = Prism.to_rad(angle)
      cos : Float32 = Math.cos(rad)
      sin : Float32 = Math.sin(rad)

      return Vector2f.new(@x * cos - @y * sin, @x * sin + @y * cos)
    end

    # Adds two vectors
    def +(r : Vector2f) : Vector2f
      return Vector2f.new(@x + r.x, @y + r.y)
    end

    # Adds a scalar value to the vector
    def +(r : Float32) : Vector2f
      return Vector2f.new(@x + r, @y + r)
    end

    # Subtracts two vectors
    def -(r : Vector2f) : Vector2f
      return Vector2f.new(@x - r.x, @y - r.y)
    end

    # Subtracts a scalar value from the vector
    def -(r : Float32) : Vector2f
      return Vector2f.new(@x - r, @y - r)
    end

    # Multiplies two vectors
    def *(r : Vector2f) : Vector2f
      return Vector2f.new(@x * r.x, @y * r.y)
    end

    # Multiplies the vector with a scalar
    def *(r : Float32) : Vector2f
      return Vector2f.new(@x * r, @y * r)
    end

    # Divides two vectors
    def /(r : Vector2f) : Vector2f
      return Vector2f.new(@x / r.x, @y / r.y)
    end

    # Divides the vector by a scalar
    def /(r : Float32) : Vector2f
      return Vector2f.new(@x / r, @y / r)
    end

    def to_string
      return "(#{@x}, #{@y})"
    end

  end

end
