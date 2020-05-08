require "crash"

module Prism
  # Provides a textured terrain model to an `Entity`
  class TexturedTerrainModel < Crash::Component
    property model, textures

    def initialize(@model : Prism::Model, @textures : Prism::TerrainTexturePack)
    end
  end
end
