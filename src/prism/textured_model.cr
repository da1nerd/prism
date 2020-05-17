require "crash"

module Prism
  # Provides a textured model to an `Entity`
  # TODO: could this be a generic that accepted different types of textures?
  #  Maybe we should just put this into stdlib.
  class TexturedModel < Crash::Component
    property model, texture

    def initialize(@model : Prism::Model, @texture : Prism::Texture2D)
    end
  end
end
