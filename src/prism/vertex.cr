require "./vector3f"

module Prism

  class Vertex

    SIZE = 5

    getter pos, tex_coord

    def initialize(@pos : Vector3f)
      initialize(@pos, Vector2f.new(0,0))
    end

    def initialize(@pos : Vector3f, @tex_coord : Vector2f)
    end

  end

end
