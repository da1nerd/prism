require "lib_gl"

module Prism
    # Represents a 3d model that has been loaded into opengl.
    class Model
        getter vao_id, vertex_count

        # Creates a new model
        # The *vao_id* is the vertex array object id.
        # the *vbos* are just an array of vertex buffers that should be deleted when the object is garbage collected.
        # The *vertex_count* is how many verticies are in the model.
        def initialize(@vao_id : Int32, @vbos : Array(LibGL::UInt), @vertex_count : Int32)
        end

        def finalize
            LibGL.delete_vertex_arrays @vao_id
            @vbos.each { |id| LibGL.delete_buffers id}
        end

        def draw
            LibGL.bind_vertex_array(@vao_id)
            LibGL.enable_vertex_attrib_array(0)
            LibGL.enable_vertex_attrib_array(1)
            offset = Pointer(Void).new(0)
            LibGL.draw_elements(LibGL::TRIANGLES, @vertex_count, LibGL::UNSIGNED_INT, offset)
            LibGL.disable_vertex_attrib_array(0)
            LibGL.disable_vertex_attrib_array(1)
            LibGL.bind_vertex_array(0)
        end

        def self.load(positions : Array(Float32), texture_coords : Array(LibGL::UInt), indicies : Array(LibGL::UInt))
            vao_id = create_vao()
            vbos = [] of LibGL::Uint
            vbos << bind_indicies_buffer(indicies)
            vbos << store_data_in_attribute_list(0, 3, positions)
            vbos << store_data_in_attribute_list(1, 2, texture_coords)
            unbind_vao
            Model.new(vao_id, vbos, indicies.size)
        end

        private def self.create_vao
            vao_id : LibGL::UInt
            LibGL.gen_vertex_arrays(1, out vao_id)
            LibGL.bind_vertex_array(1, vao_id)
            return vao_id
        end

        private def self.unbind_vao
            LibGL.bind_vertex_array 0
        end

        private def self.bind_indicies_buffer(indicies : Array(LibGL::UInt))
            vbo_id : LibGL::UInt
            LibGL.gen_buffers(1, out vbo_id)
            LibGL.bind_buffer(LibGL::ELEMENT_ARRAY_BUFFER, vbo_id)
            LibGL.buffer_data(LibGL::ELEMENT_ARRAY_BUFFER, indicies.size * sizeof(LibGL::UInt), indicies, LibGL::STATIC_DRAW)
            LibGL.bind_buffer(LibGL::ELEMENT_ARRAY_BUFFER, 0)
            return vbo_id
        end

        # Stores some data into an attribute list.
        # *coordinate_size* is how big the data is e.g. 3d coordinates, 2d coordinats.
        private def self.store_data_in_attribute_list(attribute_number : LibGL::UInt, coordinate_size : LibGL::UInt, data : Array(Float32))
            vbo_id : LibGL::UInt
            LibGL.gen_buffers(1, out vbo_id)
            LibGL.bind_buffer(LibGL::ARRAY_BUFFER, vbo_id)
            LibGL.buffer_data(LibGL::ARRAY_BUFFER, data.size * sizeof(Float32), data, LibGL::STATIC_DRAW)
            offset = Pointer(Void).new(0)
            LibGL.vertex_attrib_pointer(attribute_number, coordinate_size, LibGL::FLOAT, LibGL::FALSE, 0, offset)
            LibGL.bind_buffer(LibGL::ARRAY_BUFFER, 0)
            return vbo_id
        end
    end
end