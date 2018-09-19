module Prism

  class Util

    # Creates a flattened array of verticies for OpenGL
    def self.flatten_verticies(verticies : Array(Vertex))
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
