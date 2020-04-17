module Prism::Core::Shader
  class StaticShader < Program
    @@programs = {} of String => CompiledProgram

    # @[Field(key: "T_MVP")]
    # @model_view_projection : Matrix4f

    # @[Field(key: "materialColor")]
    # @material_color : Vector3f

    # @[Field(key: "diffuse")]
    # @texture_sampler : Texture

    # @lights : Array(Light)

    def initialize
      super("static")
    end
  end
end
