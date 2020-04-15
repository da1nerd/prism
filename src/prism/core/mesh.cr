require "lib_gl"

module Prism::Core
  struct MeshCache
    property verticies, indicies, calc_normals

    def initialize(@verticies : Array(Vertex), @indicies : Array(LibGL::Int), @calc_normals : Bool)
    end
  end

  # Manages the state of a model mesh
  # Meshes give the shapes which can be covered in `Material`s.
  # This is also known as the "model"
  # TODO: rename to "model"
  class Mesh
    @@loaded_models = {} of String => MeshResource
    @resource : MeshResource
    @file_name : String?
    @cache : MeshCache?

    def initialize(file_name : String)
      @file_name = file_name
      if @@loaded_models.has_key?(file_name)
        @resource = @@loaded_models[file_name]
        @resource.add_reference
      else
        @resource = MeshResource.new
        @@loaded_models[file_name] = @resource
      end
      load_mesh(file_name)
    end

    def initialize(verticies : Array(Vertex), indicies : Array(LibGL::Int))
      initialize(verticies, indicies, false)
    end

    def initialize(verticies : Array(Vertex), indicies : Array(LibGL::Int), calc_normals : Bool)
      @resource = MeshResource.new
      add_verticies(verticies, indicies, calc_normals)
    end

    # garbage collection
    def finalize
      if @resource.remove_reference && @file_name != nil
        @@loaded_models.delete(@file_name)
      end
    end

    private def load_mesh(file_name : String)
      ext = File.extname(file_name)

      unless ext === ".obj"
        puts "Error: File format not supported for mesh data: #{ext}"
        exit 1
      end

      test1 = Model::OBJModel.new(file_name)
      model = test1.to_indexed_model
      # model.calc_normals

      verticies = [] of Vertex
      0.upto(model.positions.size - 1) do |i|
        verticies.push(Vertex.new(model.positions[i], model.tex_coords[i], model.normals[i]))
      end

      add_verticies(verticies, model.indicies, false)
    end

    def add_verticies(verticies : Array(Vertex), indicies : Array(LibGL::Int))
      add_verticies(verticies, indicies, false)
    end

    private def add_verticies(verticies : Array(Vertex), indicies : Array(LibGL::Int), calc_normals : Bool)
      @cache = MeshCache.new(verticies, indicies, calc_normals)
      if calc_normals
        calc_normals(verticies, indicies)
      end

      @resource.size = indicies.size

      LibGL.bind_buffer(LibGL::ARRAY_BUFFER, @resource.vbo)
      LibGL.buffer_data(LibGL::ARRAY_BUFFER, verticies.size * Vertex::SIZE * sizeof(Float32), Vertex.flatten(verticies), LibGL::STATIC_DRAW)
      LibGL.bind_buffer(LibGL::ARRAY_BUFFER, 0)

      LibGL.bind_buffer(LibGL::ELEMENT_ARRAY_BUFFER, @resource.ibo)
      LibGL.buffer_data(LibGL::ELEMENT_ARRAY_BUFFER, indicies.size * Vertex::SIZE * sizeof(Float32), indicies, LibGL::STATIC_DRAW)
      LibGL.bind_buffer(LibGL::ELEMENT_ARRAY_BUFFER, 0)
    end

    # Reverses the face of the mesh
    def reverse_face
      if cache = @cache
        indicies = [] of LibGL::Int
        0.upto((cache.indicies.size // 3) - 1) do |i|
          offset = i * 3
          indicies << cache.indicies[offset + 2]
          indicies << cache.indicies[offset + 1]
          indicies << cache.indicies[offset]
        end
        self.add_verticies(cache.verticies, indicies, cache.calc_normals)
      end
    end

    def draw()
      LibGL.bind_buffer(LibGL::ARRAY_BUFFER, @resource.vbo)

      mesh_offset = Pointer(Void).new(0)
      LibGL.vertex_attrib_pointer(0, 3, LibGL::FLOAT, LibGL::FALSE, Vertex::SIZE * sizeof(Float32), mesh_offset)

      texture_offset = Pointer(Void).new(3 * sizeof(Float32)) # TRICKY: skip the three floating point numbers above
      LibGL.vertex_attrib_pointer(1, 2, LibGL::FLOAT, LibGL::FALSE, Vertex::SIZE * sizeof(Float32), texture_offset)

      normals_offset = Pointer(Void).new(5 * sizeof(Float32)) # TRICKY: skip the five floating point numbers above
      LibGL.vertex_attrib_pointer(2, 3, LibGL::FLOAT, LibGL::FALSE, Vertex::SIZE * sizeof(Float32), normals_offset)

      # Draw faces using the index buffer
      LibGL.bind_buffer(LibGL::ELEMENT_ARRAY_BUFFER, @resource.ibo)
      indicies_offset = Pointer(Void).new(0)
      LibGL.draw_elements(LibGL::TRIANGLES, @resource.size, LibGL::UNSIGNED_INT, indicies_offset)
    end

    # Calculates the up direction for all the verticies
    private def calc_normals(verticies : Array(Vertex), indicies : Array(LibGL::Int))
      i = 0
      while i < indicies.size
        i0 = indicies[i]
        i1 = indicies[i + 1]
        i2 = indicies[i + 2]
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
