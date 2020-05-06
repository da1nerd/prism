module Prism
  # DEPRECATED
  struct MeshCache
    property verticies, indicies, calc_normals

    def initialize(@verticies : Array(Prism::Vertex), @indicies : Array(LibGL::Int), @calc_normals : Bool)
    end
  end
end
