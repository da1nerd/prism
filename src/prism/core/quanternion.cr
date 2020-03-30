require "./vector3f"

module Prism
  struct Quaternion
    getter x, y, z, w

    @x : Float64
    @y : Float64
    @z : Float64
    @w : Float64

    def initialize(@x, @y, @z, @w : Float64)
    end

    # def initialize(rot : Matrix4f)
    # TODO: https://youtu.be/OJt-1qAjY7I?list=PLEETnX-uPtBXP_B2yupUKlflXBznWIlL5&t=965
    # end

    def initialize(axis : Vector3f, angle : Float32)
      sin_half_angle = Math.sin(angle.to_f64 / 2.0f64)
      cos_half_angle = Math.cos(angle.to_f64 / 2.0f64)

      @x = axis.x.to_f64 * sin_half_angle
      @y = axis.y.to_f64 * sin_half_angle
      @z = axis.z.to_f64 * sin_half_angle
      @w = cos_half_angle
    end

    def initialize(rot : Matrix4f)
      trace = (rot.[](0, 0) + rot.[](1, 1) + rot.[](2, 2)).to_f64

      if trace > 0
        s = 0.5f64 / Math.sqrt(trace + 1.0f64)
        @w = 0.25f64 / s
        @x = (rot.[](1, 2) - rot.[](2, 1)).to_f64 * s
        @y = (rot.[](2, 0) - rot.[](0, 2)).to_f64 * s
        @z = (rot.[](0, 1) - rot.[](1, 0)).to_f64 * s
      else
        if rot.[](0, 0) > rot.[](1, 1) && rot.[](0, 0) > rot.[](2, 2)
          s = 2.0f64 * Math.sqrt(1.0 + rot.[](0, 0) - rot.[](1, 1) - rot.[](2, 2)).to_f64
          @w = (rot.[](1, 2) - rot.[](2, 1)).to_f64 / s
          @x = 0.25f64 * s
          @y = (rot.[](1, 0) + rot.[](0, 1)).to_f64 / s
          @z = (rot.[](2, 0) + rot.[](0, 2)).to_f64 / s
        elsif rot.[](1, 1) > rot.[](2, 2)
          s = 2.0f64 * Math.sqrt(1.0 + rot.[](1, 1) - rot.[](0, 0) - rot.[](2, 2)).to_f64
          @w = (rot.[](2, 0) - rot.[](0, 2)).to_f64 / s
          @x = (rot.[](1, 0) + rot.[](0, 1)).to_f64 / s
          @y = 0.25f64 * s
          @z = (rot.[](2, 1) + rot.[](1, 2)).to_f64 / s
        else
          s = 2.0f64 * Math.sqrt(1.0 + rot.[](2, 2) - rot.[](0, 0) - rot.[](1, 1)).to_f64
          @w = (rot.[](0, 1) - rot.[](1, 0)).to_f64 / s
          @x = (rot.[](2, 0) + rot.[](0, 2)).to_f64 / s
          @y = (rot.[](1, 2) + rot.[](2, 1)).to_f64 / s
          @z = 0.25f64 * s
        end
      end

      length = Math.sqrt(@x * @x + @y * @y + @z * @z + @w * @w)
      @x /= length
      @y /= length
      @z /= length
      @w /= length
    end

    def values
      {@x, @y, @z, @w}
    end

    def length : Float32
      magnitude
    end

    def *(r : Quaternion)
      w = @w * r.w - @x * r.x - @y * r.y - @z * r.z
      x = @x * r.w + @w * r.x + @y * r.z - @z * r.y
      y = @y * r.w + @w * r.y + @z * r.x - @x * r.z
      z = @z * r.w + @w * r.z + @x * r.y - @y * r.x

      return Quaternion.new(x, y, z, w)
    end

    def *(r : Vector3f)
      w = -@x * r.x - @y * r.y - @z * r.z
      x = @w * r.x + @y * r.z - @z * r.y
      y = @w * r.y + @z * r.x - @x * r.z
      z = @w * r.z + @x * r.y - @y * r.x

      return Quaternion.new(x, y, z, w)
    end

    def to_rotation_matrix
      forward = Vector3f.new((2.0f64 * (@x*@z - @w*@y)).to_f32, (2.0f64 * (@y*@z + @w*@x)).to_f32, (1.0f64 - 2.0f64 * (@x*@x + @y*@y)).to_f32)
      up = Vector3f.new((2.0f64 * (@x*@y + @w*@z)).to_f32, (1.0f64 - 2.0f64 * (@x*@x + @z*@z)).to_f32, (2.0f64 * (@y*@z - @w*@x)).to_f32)
      right = Vector3f.new((1.0f64 - 2.0f64 * (@y*@y + @z*@z)).to_f32, (2.0f64 * (@x*@y - @w*@z)).to_f32, (2.0f64 * (@x*@z + @w*@y)).to_f32)

      return Matrix4f.new.init_rotation(forward, up, right)
    end

    def forward
      return Vector3f.new(0f32, 0f32, 1f32).rotate(self)
    end

    def back
      return Vector3f.new(0f32, 0f32, -1f32).rotate(self)
    end

    def up
      return Vector3f.new(0f32, 1f32, 0f32).rotate(self)
    end

    def down
      return Vector3f.new(0f32, -1f32, 0f32).rotate(self)
    end

    def right
      return Vector3f.new(1f32, 0f32, 0f32).rotate(self)
    end

    def left
      return Vector3f.new(-1f32, 0f32, 0f32).rotate(self)
    end

    # Converts euler angles to Quaternion
    # Angles are in radians!
    def self.from_euler(euler : Vector3)
      sx, sy, sz = euler.x / 2.0, euler.y / 2.0, euler.z / 2.0
      c1 = Math.cos sy
      s1 = Math.sin sy
      c2 = Math.cos sx
      s2 = Math.sin sx
      c3 = Math.cos sz
      s3 = Math.sin sz
      new(
        c1 * c2 * s3 + s1 * s2 * c3,
        s1 * c2 * c3 + c1 * s2 * s3,
        c1 * s2 * c3 - s1 * c2 * s3,
        c1 * c2 * c3 - s1 * s2 * s3
      )
    end

    def to_euler
      sqw = self.w**2
      sqx = self.x**2
      sqy = self.y**2
      sqz = self.z**2
      unit = sqx + sqy + sqz + sqw
      test = self.x*self.y + self.z*self.w
      if test > 0.4999 * unit
        Vector3.new(
          Math::PI/2,
          2 * Math.atan2(self.x, self.w),
          0.0
        )
      elsif test < -0.4999 * unit
        Vector3.new(
          -Math::PI/2,
          -2 * Math.atan2(self.x, self.w),
          0.0
        )
      else
        Vector3.new(
          Math.asin(2*test/unit),
          Math.atan2(2 * self.y * self.w - 2 * self.x * self.z, sqx - sqy - sqz + sqw),
          Math.atan2(2 * self.x * self.w - 2 * self.y * self.z, -sqx + sqy - sqz + sqw)
        )
      end
    end

    # Zero vector
    def self.zero
      new(0.0, 0.0, 0.0, 0.0)
    end

    # Dot product
    def dot(other : Quaternion)
      x*other.x + y*other.y + z*other.z + w*other.w
    end

    def **(other : Quaternion)
      dot other
    end

    def norm
      self.x**2 + self.y**2 + self.z**2 + self.w**2
    end

    def magnitude
      Math.sqrt(self.x**2 + self.y**2 + self.z**2 + self.w**2)
    end

    def +(other : Quaternion)
      Quaternion.new(self.x + other.x, self.y + other.y, self.z + other.z, self.w + other.w)
    end

    def -(other : Quaternion)
      Quaternion.new(self.x - other.x, self.y - other.y, self.z - other.z, self.w - other.w)
    end

    def -
      Quaternion.new(-self.x, -self.y, -self.z, -self.w)
    end

    def *(other : Vector3)
      Quaternion.new(
        self.w * other.x + self.y * other.z - self.z * other.y,
        self.w * other.y - self.x * other.z + self.z * other.x,
        self.w * other.z + self.x * other.y - self.y * other.x,
        0 - self.x*other.x - self.y*other.y - self.z * other.z
      )
    end

    def *(other : Float64)
      Quaternion.new(self.x*other, self.y * other, self.z * other, self.w * other)
    end

    def inverse
      if norm == 0.0
        self
      else
        self.conjugate.normalize
      end
    end

    def conjugate
      Quaternion.new(-@x, -@y, -@z, @w)
    end

    def pure?
      self.w == 0.0
    end

    def unit?
      norm == 1.0
    end

    def axis
      Vector3.new(x, y, z)
    end

    def axis=(v : Vector3)
      @x, @y, @z = v.x, v.y, v.z
    end

    def angle
      @w
    end

    def angle=(v : Float64)
      @w = v
    end

    def clone
      Quaternion.new(self.x, self.y, self.z, self.w)
    end

    def normalize!
      m = magnitude
      unless m == 0
        @x /= m
        @y /= m
        @z /= m
        @w /= m
      end
      self
    end

    def normalize
      clone.normalize!
    end

    def_equals x, y, z, w

    def !=(other : Quaternion)
      self.x != other.x || self.y != other.y || self.z != other.z || self.w != other.w
    end

    def ==(r : Quaternion) : Bool
      return @x == r.x && @y == r.y && @z == r.z && @w == r.w
    end

    def set(@x : Float64, @y : Float64, @z : Float64, @w : Float64)
      self
    end

    def set(r : Quaternion)
      self.set(r.x, r.y, r.z, r.w)
      self
    end

    def to_s
      "{X : #{x}; Y : #{y}, Z : #{z}, W: : #{w}}"
    end

    # Normalized linear interpolation.
    #
    # This is technically cheaper than `slerp` however it's usually negligable.
    # For the most part you can choose whichever one looks best
    def nlerp(dest : Quaternion, lerp_factor : Float64, shortest : Bool) : Quaternion
      corrected_dest = dest.clone
      if shortest && self.dot(dest) < 0
        corrected_dest = Quaternion.new(-dest.x, -dest.y, -dest.z, -dest.w)
      end
      return ((corrected_dest - self) * lerp_factor + self).normalize
    end

    # Spherical linear interpolation.
    #
    # This gives a guaranteed linear movement whereas `nlerp` does not.
    # This is technically more expensive than `nlerp` however it's usually negligable.
    # For the most part you can choose whichever one looks best
    def slerp(dest : Quaternion, lerp_factor : Float64, shortest : Bool) : Quaternion
      epsilon = 1e3f32

      cos = self.dot(dest)
      corrected_dest = dest.clone

      if shortest && cos < 0
        cos = -cos
        corrected_dest = Quaternion.new(-dest.x, -dest.y, -dest.z, -dest.w)
      end

      if cos.abs >= 1 - epsilon
        return nlerp(corrected_dest, lerp_factor, false)
      end

      sin = Math.sqrt(1.0f64 - cos * cos)
      angle = Math.atan2(sin, cos)
      inv_sin = 1.0f64 / sin

      src_factor = Math.sin((1.0f64 - lerp_factor) - angle) * inv_sin
      dest_factor = Math.sin(lerp_factor * angle) * inv_sin

      return self * src_factor + (corrected_dest * dest_factor)
    end

    def self.lerp(qstart, qend : Quaternion, percent : Float64)
      if percent == 0
        return qstart
      elsif percent == 1
        return qend
      else
        f1 = 1.0 - percent
        f2 = percent

        return Quaternion.new(
          f1 * qstart.x + f2 * qend.x,
          f1 * qstart.y + f2 * qend.y,
          f1 * qstart.z + f2 * qend.z,
          f1 * qstart.w + f2 * qend.w
        )
      end
    end

    def self.nlerp(qstart, qend : Quaternion, percent : Float64)
      lerp(qstart, qend, percent).normalize
    end

    def self.slerp(qstart, qend : Quaternion, percent : Float64)
      if percent == 0
        return qstart
      elsif percent == 1
        return qend
      else
        dot = qstart**qend
        if dot == 0
          return lerp(qstart, qend, percent)
        elsif dot < 0
          return -slerp(qstart, -qend, percent)
        else
          dot = dot.clamp(-1.0, 1.0)
          theta = Math.acos(dot)
          s = Math.sin(theta)
          f1 = Math.sin((1.0 - percent) * theta) / s
          f1 = Math.sin(percent * theta) / s
          return Quaternion.new(
            f1 * qstart.x + f2 * qend.x,
            f1 * qstart.y + f2 * qend.y,
            f1 * qstart.z + f2 * qend.z,
            f1 * qstart.w + f2 * qend.w
          )
        end
      end
    end
  end

  struct Vector3
    def rotate(q : Quaternion)
      qi = q.conjugate
      qq = (q*self)*qi
      Vector3.new(
        qq.x,
        qq.y,
        qq.z
      )
    end

    def reflect(q : Quaternion)
      qq = ((q*self)*q).normalize
      Vector3.new(
        qq.x,
        qq.y,
        qq.z
      )
    end
  end
end
