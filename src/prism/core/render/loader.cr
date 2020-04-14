require "lib_gl"

module Prism::Core::Render
  # Takes the positions of a model's verticies and loads them into a vertex attribute object and returns information about the vertex attribute object as a `RawModel` object.
  #
  # This is how the data flows
  # ```
  # vertex data (mesh) -> vertex buffer object -> vertex attribute object
  # ```
  class Loader
    @vaos = [] of Int32
    @vbos = [] of Int32

    # Clean up memory
    def finalize
      @vaos.each do |id|
        LibGL.delete_vertex_arrays(id)
      end
      @vbos.each do |id|
        LibGL.delete_buffers(id)
      end
    end

    # Loads the vertex positions into a vertex attibute object.
    def load_to_vao(positions : Array(Float32), indicies : Array(Int32)) : RawModel
      vao_id : Int32 = create_vao
      bind_indicies_buffer(indicies)
      store_data_in_attribute_list(0, positions)
      unbind_vao
      RawModel.new(vao_id, indicies.size)
    end

    # Create a new vertex attribute object
    private def create_vao : Int32
      vao_id : Int32 = LibGL.gen_vertex_arrays
      vaos.push(vao_id)
      LibGL.bind_vertex_array(vao_id)
      vao_id
    end

    # Stores vertex data in a vertex buffer object
    private def store_data_in_attribute_list(attribute_number : Int32, data : Array(Float32))
      vbo_id = LibGL.gen_buffers
      vbos.push(vbo_id)
      LibGL.bind_buffer(LibGL::ARRAY_BUFFER, vbo_id)
      LibGL.buffer_data(LibGL::ARRAY_BUFFER, data, LibGL::STATIC_DRAW)
      # The first 0 is the distance between verticies. If we store other things like
      # texture coords or normals we'll need to put a number here.
      LibGL.vertex_attrib_pointer(attribute_number, 3, LibGL::FLOAT, false, 0, 0)
      LibGL.bind_buffer(LibGL::ARRAY_BUFFER, 0)
    end

    # Unbind the vertex attribute object
    private def unbind_vao
      LibGL.bind_vertex_array(0)
    end

    private def bind_indicies_buffer(indicies : Array(Int32))
        vbo_id = LibGL.gen_buffers
        vbos.push(vbo_id)
        LibGL.bind_buffer(LibGL::ELEMENT_ARRAY_BUFFER, vbo_id)
        LibGL.buffer_data(LibGL::ELEMENT_ARRAY_BUFFER, indicies, LibGL::STATIC_DRAW)
        LibGL.bind_buffer(LibGL::ELEMENT_ARRAY_BUFFER, 0)
    end
  end
end
