module Prism

  class Util
    def self.create_flipped_buffer(verticies : Array(Vertex))
      buffer = [] of Float32

      verticies.each do |v|
        buffer.push(v.pos.x)
        buffer.push(v.pos.y)
        buffer.push(v.pos.z)
      end

      buffer.reverse!
      return buffer
    end
  end

end
