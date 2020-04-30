require "crash"

module Prism
  # Provides a textured mesh to an `Entity`
  class TexturedModel < Crash::Component
    property mesh, texture

    def initialize(@mesh : Prism::Mesh, @texture : Prism::TexturePack)
    end
  end
end
