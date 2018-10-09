require "lib_gl"
require "./util"
require "./vertex"

module Prism

  class Mesh

    @vbo : LibGL::UInt
    @ibo : LibGL::UInt
    @size : Int32

    def initialize(file_name : String)
      LibGL.gen_buffers(1, out @vbo)
      LibGL.gen_buffers(1, out @ibo)
      @size = 0
      load_mesh(file_name)
    end

    def initialize(verticies : Array(Vertex), indicies : Array(LibGL::Int))
      initialize(verticies, indicies, false)
    end

    def initialize(verticies : Array(Vertex), indicies : Array(LibGL::Int), calc_normals : Bool)
      LibGL.gen_buffers(1, out @vbo)
      LibGL.gen_buffers(1, out @ibo)
      @size = 0
      add_verticies(verticies, indicies, calc_normals)
    end

    # def initialize
      # LibGL.gen_buffers(1, out @vbo)
      # LibGL.gen_buffers(1, out @ibo)
      # @size = 0
    # end

    private def load_mesh(file_name : String)
      ext = File.extname(file_name)

      teststuff = OBJModel.new(File.join(File.dirname(PROGRAM_NAME), "/res/models/", file_name))

      unless ext === ".obj"
        puts "Error: File format not supported for mesh data: #{ext}"
        exit 1
      end

      verticies = [] of Vertex
      indicies = [] of LibGL::Int

      path = File.join(File.dirname(PROGRAM_NAME), "/res/models/", file_name)
      File.each_line(path) do |line|
        tokens = line.split(" ", remove_empty: true)
        if tokens.size === 0 || tokens[0] === "#"
          next
        elsif tokens[0] === "v"
          v = Vector3f.new(tokens[1].to_f32, tokens[2].to_f32, tokens[3].to_f32)
          verticies.push(Vertex.new(v))
        elsif tokens[0] === "f"
          indicies.push(tokens[1].split("/")[0].to_i32 - 1);
          indicies.push(tokens[2].split("/")[0].to_i32 - 1);
          indicies.push(tokens[3].split("/")[0].to_i32 - 1);

          if tokens.size > 4
            indicies.push(tokens[1].split("/")[0].to_i32 - 1);
            indicies.push(tokens[3].split("/")[0].to_i32 - 1);
            indicies.push(tokens[4].split("/")[0].to_i32 - 1);
          end
        end
      end

      add_verticies(verticies, indicies)
    end

    def add_verticies(verticies : Array(Vertex), indicies : Array(LibGL::Int))
      add_verticies(verticies, indicies, false)
    end

    private def add_verticies(verticies : Array(Vertex), indicies : Array(LibGL::Int), calc_normals : Bool)
        if calc_normals
          calc_normals(verticies, indicies)
        end

        @size = indicies.size

        LibGL.bind_buffer(LibGL::ARRAY_BUFFER, @vbo)
        LibGL.buffer_data(LibGL::ARRAY_BUFFER, verticies.size * Vertex::SIZE * sizeof(Float32), Util.flatten_verticies(verticies), LibGL::STATIC_DRAW)

        LibGL.bind_buffer(LibGL::ELEMENT_ARRAY_BUFFER, @ibo)
        LibGL.buffer_data(LibGL::ELEMENT_ARRAY_BUFFER, indicies.size * Vertex::SIZE * sizeof(Float32), indicies, LibGL::STATIC_DRAW)
    end

    def draw
      LibGL.enable_vertex_attrib_array(0)
      LibGL.enable_vertex_attrib_array(1)
      LibGL.enable_vertex_attrib_array(2)

      LibGL.bind_buffer(LibGL::ARRAY_BUFFER, @vbo)

      mesh_offset = Pointer(Void).new(0)
      LibGL.vertex_attrib_pointer(0, 3, LibGL::FLOAT, LibGL::FALSE, Vertex::SIZE * sizeof(Float32), mesh_offset)

      texture_offset = Pointer(Void).new(3 * sizeof(Float32)) # TRICKY: skip the three floating point numbers above
      LibGL.vertex_attrib_pointer(1, 2, LibGL::FLOAT, LibGL::FALSE, Vertex::SIZE * sizeof(Float32), texture_offset)

      normals_offset = Pointer(Void).new(5 * sizeof(Float32)) # TRICKY: skip the five floating point numbers above
      LibGL.vertex_attrib_pointer(2, 3, LibGL::FLOAT, LibGL::FALSE, Vertex::SIZE * sizeof(Float32), normals_offset)

      # Draw faces using the index buffer
      LibGL.bind_buffer(LibGL::ELEMENT_ARRAY_BUFFER, @ibo)
      indicies_offset = Pointer(Void).new(0)
      LibGL.draw_elements(LibGL::TRIANGLES, @size, LibGL::UNSIGNED_INT, indicies_offset)

      LibGL.disable_vertex_attrib_array(0)
      LibGL.disable_vertex_attrib_array(1)
      LibGL.disable_vertex_attrib_array(2)
    end

    # Calculates the up direction for all the verticies
    private def calc_normals(verticies : Array(Vertex), indicies : Array(LibGL::Int))
      i = 0
      while i < indicies.size
        i0 = indicies[i];
        i1 = indicies[i + 1];
        i2 = indicies[i + 2];

        v1 = Vector3f.new(verticies[i1].pos - verticies[i0].pos)
        v2 = Vector3f.new(verticies[i2].pos - verticies[i0].pos)

        normal = v1.cross(v2).normalized

        verticies[i0].normal = verticies[i0].normal + normal
        verticies[i1].normal = verticies[i1].normal + normal
        verticies[i2].normal = verticies[i2].normal + normal

        i += 3
      end

      i = 0
      while i < verticies.size
        verticies[i].normal = verticies[i].normal.normalized

        i += 1
      end

    end

  end

end
