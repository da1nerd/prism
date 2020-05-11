require "../light.cr"

module Prism
  # An experiment with lights
  class NewLight < Prism::Light
    @[Prism::Shader::Field]
    @position : Vector3f

    @[Prism::Shader::Field]
    @color : Vector3f

    property color, position

    def initialize(@position, @color)
    end
  end
end
