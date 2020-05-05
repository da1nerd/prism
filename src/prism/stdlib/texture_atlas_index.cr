module Prism
  # This is meant to be used with a texture that has a `TextureAtlas` size greater than 1.
  # Adding this to your entity will indicate which index of the atlas to render.
  # I'm not very pleased with this API at the moment, but it will work for now.
  class TextureAtlasIndex < Crash::Component
    getter index

    def initialize(@index : UInt32)
    end
  end
end
