module Prism
  # Contains some extra metadata about how an object should be rendered
  # TODO: I don't like this. It's far too specific and not very flexible.
  #  We need some material values for terrain, and different ones for other entities.
  #  We probably need to just have a different material class for terrain and entities.
  class Material < Crash::Component
    property specular_intensity, specular_power, color, use_fake_lighting

    # Indicates that this material has transparency
    setter has_transparency, wire_frame

    # Indicates the material should be drawn as a wire frame instead of filled
    @wire_frame : Bool = false

    # Indicates if this material has transparency
    @has_transparency : Bool = false

    # This allows you to simulate some half decent lighting.
    # This is helpful when rendering entities that are composed of a bunch of flat surfaces. e.g. plants, trees, etc.
    # @[Prism::Shader::Field(name: "useFakeLighting")]
    @use_fake_lighting : Bool = false

    # The reflectivity determines how shiny the surface of the object is.
    # @[Prism::Shader::Field(name: "specularIntensity")]
    @specular_intensity : Float32 = 0.7

    # The shine dampening determines how close the camera has to be
    # to the reflected light to see any change in the brightness on surface of the object.
    # @[Prism::Shader::Field(name: "specularPower")]
    @specular_power : Float32 = 10

    # The color of the surface of the object.
    # this defaults to black
    # @[Prism::Shader::Field(name: "materialColor")]
    @color : Vector3f = Vector3f.new(0, 0, 0)

    # Checks if this material has any transparency
    def has_transparency?
      @has_transparency
    end

    def wire_frame?
      @wire_frame
    end
  end
end
