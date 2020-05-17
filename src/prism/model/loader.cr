require "lib_gl"
require "./obj"

module Prism
  class Model
    # Loads an OBJ file into opengl and returns a model object that can be used for drawing.
    def self.load(file_name : String) : Prism::Model
      load(OBJ.load(file_name))
    end

    def self.load(data : ModelData) : Prism::Model
      load(data.vertices, data.texture_coords, data.normals, data.indices)
    end

    # Loads some 2d vertices into a model.
    # This is useful for creating models for the GUI
    def self.load_2f(vertices : Array(Float32))
      if vertices.size % 2 != 0
        raise "2d vertices expected."
      end
      vao_id = create_vao
      vbos = [] of LibGL::UInt
      vbos << store_data_in_attribute_list(0, 2, vertices)
      unbind_vao
      Model.new(vao_id, vbos, (vertices.size / 2).to_i32, vbos.size)
    end

    # Loads some 3d vertices into a model.
    def self.load_3f(vertices : Array(Float32))
      if vertices.size % 3 != 0
        raise "3d vertices expected."
      end
      vao_id = create_vao
      vbos = [] of LibGL::UInt
      vbos << store_data_in_attribute_list(0, 3, vertices)
      unbind_vao
      Model.new(vao_id, vbos, (vertices.size / 3).to_i32, vbos.size)
    end

    # Loads some raw data into open gl and returns a model object that can be used for drawing.
    # This is designed to load 3d vertices
    def self.load(vertices : Array(Float32), texture_coords : Array(Float32), normals : Array(Float32), indicies : Array(Int32)) : Prism::Model
      vao_id = create_vao
      vbos = [] of LibGL::UInt
      vbos << bind_indicies_buffer(indicies)
      vbos << store_data_in_attribute_list(0, 3, vertices)
      vbos << store_data_in_attribute_list(1, 2, texture_coords)
      vbos << store_data_in_attribute_list(2, 3, normals)
      unbind_vao
      # TRICKY: one of the vbos is for the indicies, so we don't need an attribute array for that.
      num_attrib_arrays = vbos.size - 1
      Model.new(vao_id, vbos, indicies.size, num_attrib_arrays)
    end

    # Creates a new vertex array object so we can store all of our buffered data.
    private def self.create_vao
      LibGL.gen_vertex_arrays(1, out vao_id)
      LibGL.bind_vertex_array(vao_id)
      return vao_id
    end

    private def self.unbind_vao
      LibGL.bind_vertex_array 0
    end

    private def self.bind_indicies_buffer(indicies : Array(Int32))
      LibGL.gen_buffers(1, out vbo_id)
      LibGL.bind_buffer(LibGL::ELEMENT_ARRAY_BUFFER, vbo_id)
      LibGL.buffer_data(LibGL::ELEMENT_ARRAY_BUFFER, indicies.size * sizeof(Int32), indicies, LibGL::STATIC_DRAW)
      return vbo_id
    end

    # Stores some data into an attribute list.
    # *attribute_number* is which attribute the data will be bound to. You should use sequental numbers starting at 0 otherwise something may break.
    # *coordinate_size* is how big the data is e.g. 3d coordinates, 2d coordinats.
    # if your data is a 3d vector you should set the value to 3.
    private def self.store_data_in_attribute_list(attribute_number : LibGL::UInt, coordinate_size : LibGL::UInt, data : Array(Float32))
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
