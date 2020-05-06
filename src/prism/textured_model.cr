require "crash"

module Prism
  # Provides a textured model to an `Entity`
  class TexturedModel < Crash::Component
    property model, texture

    # TODO: I'm not sure we should use `TexturePack` here. The texture pack is probably most useful for terrain
    #  So this is probably overkill. We can use something other than `TexturedModel` for the `Terrain`.
    def initialize(@model : Prism::Model, @texture : Prism::TexturePack)
    end
  end
end
