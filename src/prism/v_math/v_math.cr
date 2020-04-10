require "./**"

# Vector math
# TODO: move this into a separate library or use an existing library.
module Prism::VMath
  extend self

  # converts degrees to radians
  def to_rad(degree : Float32) : Float32
    return degree / 180.0f32 * Math::PI
  end
end
