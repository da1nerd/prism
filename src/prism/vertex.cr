require "./vector3f"

module Prism

  class Vertex

    SIZE = 8

    getter pos, tex_coord, normal
    setter normal

    def initialize(@pos : Vector3f)
      initialize(@pos, Vector2f.new(0,0))
    end

    def initialize(@pos : Vector3f, @tex_coord : Vector2f)
      initialize(@pos, @tex_coord, Vector3f.new(0,0,0))
    end

    def initialize(@pos : Vector3f, @tex_coord : Vector2f, @normal : Vector3f)
    end

  end

end
