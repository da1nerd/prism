require "./shader"

module Prism
  # Fundamental light component
  abstract class Light < Prism::Component
    include Prism::Shader::Serializable
  end
end
