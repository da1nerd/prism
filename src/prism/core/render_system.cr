require "crash"
require "annotation"

module Prism::Core
    class RenderSystem < Crash::System
        @nodes : Array(Crash::Node)

        def initialize()
            @nodes = [] of Crash::Node
        end

        @[Override]
        def add_to_engine(engine : Crash::Engine)
            @nodes = engine.get_node_list RenderNode
        end

        @[Override]
        def update(time : Float64)
            # TODO: render the nodes
            @nodes.each do |raw_node|
                node = raw_node.as(RenderNode)
                puts "rendering node"
            end
        end

        @[Override]
        def remove_from_engine(engine : Crash::Engine)
            @nodes.clear
        end
    end
end