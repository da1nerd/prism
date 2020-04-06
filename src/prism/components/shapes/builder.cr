require "./shape"

module Prism
  module Shapes
    class Shape::Builder
      @spritemap : Spritemap?
      @verticies : Array(Vertex)
      @indicies : Array(GraphicsInt)

      def initialize
        initialize(nil)
      end

      def initialize(@spritemap)
        super()
        @verticies = [] of Vertex
        @indicies = [] of GraphicsInt
      end

      def add_point(point : Vector3f)
      end

      # Converts the raw data into a shape
      def to_shape : Shape
        if sprites = @spritemap
          Shape.new(Mesh.new(@verticies, @indicies, true), sprites.material)
        else
          Shape.new(Mesh.new(@verticies, @indicies, true))
        end
      end
    end
  end
end
