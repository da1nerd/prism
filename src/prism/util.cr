module Prism

  class Util

    # Creates a flattened array of verticies for OpenGL
    def self.flatten_verticies(verticies : Array(Vertex))
      buffer = [] of Float32

      verticies.each do |v|
        buffer.push(v.pos.x)
        buffer.push(v.pos.y)
        buffer.push(v.pos.z)
      end

      return buffer
    end
  end

end
