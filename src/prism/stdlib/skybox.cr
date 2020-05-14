require "crash"
require "../input_receiver.cr"

module Prism
  class Skybox < Crash::Component
    getter day_texture, night_texture, size

    def initialize(@day_texture : Prism::TextureCubeMap, @night_texture : Prism::TextureCubeMap, @size : Float32)
    end
  end
end
