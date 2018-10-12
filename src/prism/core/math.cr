module Prism
  extend self

  # converts degrees to radians
  def to_rad(degree : Float32) : Float32
    return degree / 180.0f32 * Math::PI
  end
end
