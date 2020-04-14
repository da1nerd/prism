module Prism::Core::Render
  # Represents a 3D model stored in memory.
  struct RawModel
    # The vertex attribute object id
    getter vao_id

    # The number of verticies stored in the vertex attribute object
    getter vertex_count

    def initialize(@vao_id : Int32, @vertex_count : Int32)
    end
  end
end
