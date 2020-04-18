module Prism::Core
    class Renderer
        def initialize(@shader : Shader::Program)
        end
        # TODO: this will render entities for a specific shader
    end
end