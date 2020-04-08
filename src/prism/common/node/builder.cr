require "./shape"

module Prism::Common::Node
  class Shape::Builder
    @spritemap : Spritemap?
    @verticies : Array(Core::Vertex)
    @indicies : Array(Core::GraphicsInt)

    def initialize
      initialize(nil)
    end

    def initialize(@spritemap)
      super()
      @verticies = [] of Core::Vertex
      @indicies = [] of Core::GraphicsInt
    end

    def add_point(point : Vector3f)
    end

    # Converts the raw data into a shape
    def to_shape : Shape
      if sprites = @spritemap
        Shape.new(Core::Mesh.new(@verticies, @indicies, true), sprites.material)
      else
        Shape.new(Core::Mesh.new(@verticies, @indicies, true))
      end
    end
  end
end
