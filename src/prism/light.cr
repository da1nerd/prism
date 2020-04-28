require "./shader"
require "crash"

module Prism
  # Fundamental light component
  abstract class Light < Crash::Component
    include Prism::Shader::Serializable
  end
end
