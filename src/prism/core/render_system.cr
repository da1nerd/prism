require "crash"
require "annotation"

module Prism::Core
    class RenderSystem < Crash::System
        @entities : Array(Crash::Entity)

        def initialize()
            @entities = [] of Crash::Entity
        end

        @[Override]
        def add_to_engine(engine : Crash::Engine)
            @entities = engine.get_entities Prism::Core::Material, Prism::Core::Mesh
        end

        @[Override]
        def update(time : Float64)
            @entities.each do |entity|
                mesh = entity.get(Prism::Core::Mesh)
                puts "rendering node"
            end
        end

        @[Override]
        def remove_from_engine(engine : Crash::Engine)
            @entities.clear
        end
    end
end