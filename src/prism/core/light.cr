require "./shader"
require "./component"

module Prism::Core
  # Fundamental light component
  abstract class Light < Component
    include Shader::Serializable

    def add_to_engine(engine : Core::RenderingEngine)
      engine.add_light(self)
    end
  end
end
