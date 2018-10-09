module Prism

  class OBJIndex

    @vertex_index : Int32
    @tex_coord_index : Int32
    @normal_index : Int32

    setter vertex_index, tex_coord_index, normal_index
    getter vertex_index, tex_coord_index, normal_index

    def initialize
      @vertex_index = 0
      @tex_coord_index = 0
      @normal_index = 0
    end

  end

end
