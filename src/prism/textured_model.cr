require "crash"

module Prism
  # Provides a textured mesh to an `Entity`
  class TexturedModel < Crash::Component
    property mesh, material

    def initialize(@mesh : Prism::Mesh, @material : Prism::Material)
    end
  end
end
