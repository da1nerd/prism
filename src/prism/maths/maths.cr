require "./**"

# Vector math
# TODO: move this into a separate library or use an existing library.
module Prism::Maths
  extend self

  # converts degrees to radians
  def to_rad(degree : Float32) : Float32
    return degree / 180.0f32 * Math::PI
  end

  # Calculates the berry centric weight for a point between 3 vetices
  def barry_centric_weight(p1 : Vector3f, p2 : Vector3f, p3 : Vector3f, pos : Vector2f) : Float32
    det : Float32 = (p2.z - p3.z) * (p1.x - p3.x) + (p3.x - p2.x) * (p1.z - p3.z)
    l1 : Float32 = ((p2.z - p3.z) * (pos.x - p3.x) + (p3.x - p2.x) * (pos.y - p3.z)) / det
    l2 : Float32 = ((p3.z - p1.z) * (pos.x - p3.x) + (p1.x - p3.x) * (pos.y - p3.z)) / det
    l3 : Float32 = 1.0f32 - l1 - l2
    l1 * p1.y + l2 * p2.y + l3 * p3.y
  end
end
