require "crash"

module Prism
  # Provides a textured model to an `Entity`
  class TexturedModel < Crash::Component
    property model, texture

    def initialize(@model : Prism::Model, @texture : Prism::Texture2D)
    end
  end
end
