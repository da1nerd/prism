module Prism
  struct Vertex
    SIZE = 8

    getter pos, tex_coord, normal
    setter normal

    def initialize(@pos : Vector3f)
      initialize(@pos, Vector2f.new(0.0f32, 0.0f32))
    end

    def initialize(@pos : Vector3f, @tex_coord : Vector2f)
      initialize(@pos, @tex_coord, Vector3f.new(0.0f32, 0.0f32, 0.0f32))
    end

    def initialize(@pos : Vector3f, @tex_coord : Vector2f, @normal : Vector3f)
    end

    # Creates a flattened array of verticies for use in OpenGL
    def self.flatten(verticies : Array(Vertex))
      buffer = [] of Float32

      verticies.each do |v|
        buffer.push(v.pos.x)
        buffer.push(v.pos.y)
        buffer.push(v.pos.z)
        buffer.push(v.tex_coord.x)
        buffer.push(v.tex_coord.y)
        buffer.push(v.normal.x)
        buffer.push(v.normal.y)
        buffer.push(v.normal.z)
      end

      return buffer
    end
  end
end
