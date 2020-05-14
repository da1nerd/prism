require "crash"

module Prism
  class Skybox < Crash::Component
    getter texture, size

    def initialize(@texture : Prism::TextureCubeMap, @size : Float32)
    end
  end
end
