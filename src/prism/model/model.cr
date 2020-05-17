require "lib_gl"
require "./loader.cr"

module Prism
  # Represents a 3d model that has been loaded into opengl.
  class Model
    getter vao_id, vertex_count

    # Creates a new model
    # The *vao_id* is the vertex array object id.
    # the *vbos* are just an array of vertex buffers that should be deleted when the object is garbage collected.
    # The *vertex_count* is how many verticies are in the model.
    # the *num_attrib_arrays* indicates how many vertex attribute arrays need to be used.
    def initialize(@vao_id : LibGL::UInt, @vbos : Array(LibGL::UInt), @vertex_count : Int32, @num_attrib_arrays : Int32)
    end

    # Deletes the vertex array and buffers durring garbage collection.
    def finalize
      LibGL.delete_vertex_arrays(1, out @vao_id)
      @vbos.each { |id| LibGL.delete_buffers(1, pointerof(id)) }
    end

    def bind
      LibGL.bind_vertex_array(@vao_id)

      # enable attributes
      0.upto(@num_attrib_arrays - 1) do |i|
        LibGL.enable_vertex_attrib_array(i)
      end
    end

    def unbind
      # disable attributes
      0.upto(@num_attrib_arrays - 1) do |i|
        LibGL.disable_vertex_attrib_array(i)
      end

      LibGL.bind_vertex_array(0)
    end

    # Convenience method to draw the model.
    # This draws using `LibGL::TRIANGLES`.
    # You can always manually draw using the `#bind` and `#unbind` mthods.
    def draw
      bind
      offset = Pointer(Void).new(0)
      LibGL.draw_elements(LibGL::TRIANGLES, @vertex_count, LibGL::UNSIGNED_INT, offset)
      unbind
    end
  end
end
