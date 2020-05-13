module Prism
  # Represents a spot light
  class SpotLight < Prism::Light
    property cutoff

    @[Field]
    @cutoff : Float32

    @[Field(name: "pointLight")]
    @point_light : PointLight

    def initialize
      initialize(Vector3f.new(1, 1, 1), 1, Prism::Attenuation.new(0.0f32, 0.0f32, 1f32), 0.5)
    end

    def initialize(color : Vector3f)
      initialize(color, 1, Prism::Attenuation.new(0.0f32, 0.0f32, 0.1f32), 0.8)
    end

    def initialize(color : Vector3f, intensity : Float32, attenuation : Prism::Attenuation, @cutoff : Float32)
      @point_light = PointLight.new(color, intensity, attenuation)
    end
  end
end
