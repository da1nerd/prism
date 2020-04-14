require "lib_gl"

module Prism::Core::Render
  # Takes the positions of a model's verticies and loads them into a vertex attribute object and returns information about the vertex attribute object as a `RawModel` object.
  #
  # This is how the data flows
  # ```
  # vertex data (mesh) -> vertex buffer object -> vertex attribute object
  # ```
  class Loader
    @vaos = [] of UInt32
    @vbos = [] of UInt32

    # Clean up memory
    def finalize
      @vaos.each do |id|
        LibGL.delete_vertex_arrays(1, pointerof(id))
      end
      @vbos.each do |id|
        LibGL.delete_buffers(1, pointerof(id))
      end
    end

    # Loads the vertex positions into a vertex attibute object.
    # This is the same as `Mesh.add_verticies`
    def load_to_vao(positions : Array(Float32), indicies : Array(UInt32)) : RawModel
      vao_id : UInt32 = create_vao
      bind_indicies_buffer(indicies)
      store_data_in_attribute_list(0, positions)
      unbind_vao
      RawModel.new(vao_id, indicies.size)
    end

    # Create a new vertex attribute object
    private def create_vao : UInt32
      LibGL.gen_vertex_arrays(1, out vao_id)
      @vaos.push(vao_id)
      LibGL.bind_vertex_array(vao_id)
      vao_id
    end

    # Stores vertex data in a vertex buffer object
    private def store_data_in_attribute_list(attribute_number : UInt32, data : Array(Float32))
      LibGL.gen_buffers(1, out vbo_id)
      @vbos.push(vbo_id)
      LibGL.bind_buffer(LibGL::ARRAY_BUFFER, vbo_id)
      LibGL.buffer_data(LibGL::ARRAY_BUFFER, data.size * sizeof(Float32), data, LibGL::STATIC_DRAW)
      # The first 0 is the distance between verticies. If we store other things like
      # texture coords or normals we'll need to put a number here.
      LibGL.vertex_attrib_pointer(attribute_number, 3, LibGL::FLOAT, LibGL::FALSE, 0, Pointer(Void).new(0))
      LibGL.bind_buffer(LibGL::ARRAY_BUFFER, 0)
    end

    # Unbind the vertex attribute object
    private def unbind_vao
      LibGL.bind_vertex_array(0)
    end

    private def bind_indicies_buffer(indicies : Array(UInt32))
      LibGL.gen_buffers(1, out vbo_id)
      @vbos.push(vbo_id)
      LibGL.bind_buffer(LibGL::ELEMENT_ARRAY_BUFFER, vbo_id)
      LibGL.buffer_data(LibGL::ELEMENT_ARRAY_BUFFER, indicies.size * sizeof(Float32), indicies, LibGL::STATIC_DRAW)
      LibGL.bind_buffer(LibGL::ELEMENT_ARRAY_BUFFER, 0)
    end
  end
end
