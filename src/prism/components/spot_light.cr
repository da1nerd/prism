require "./point_light"

module Prism
  # Represents a spot light
  class SpotLight < PointLight
    include Uniform::Serializable

    @[Uniform::Field(struct: "SpotLight", key: "cutoff")]
    @cutoff : Float32
    property cutoff

    def initialize
      initialize(Vector3f.new(0, 0, 1), 0.5, Attenuation.new(0.0f32, 0.0f32, 0.5f32), 0.9)
    end

    def initialize(color : Vector3f)
      initialize(color, 0.5, Attenuation.new(0.0f32, 0.0f32, 0.1f32), 0.7)
    end

    def initialize(color : Vector3f, intensity : Float32, attenuation : Attenuation, @cutoff : Float32)
      super(color, intensity, attenuation)
      self.shader = Shader.new("forward-spot")
    end

    def direction
      return self.transform.get_transformed_rot.forward
    end
  end
end
