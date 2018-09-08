require "./vector3f"
require "./mesh"
require "./vertex"

module Prism
  class ResourceLoader
    # Loads a shader from the disk
    def self.load_shader(file_name : String) : String
      path = File.join(File.dirname(PROGRAM_NAME), "/res/shaders/", file_name)
      return File.read(path)
    end

    def self.load_mesh(file_name : String) : Mesh
      ext = File.extname(file_name)
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
          indicies.push(tokens[1].to_i32 - 1);
          indicies.push(tokens[2].to_i32 - 1);
          indicies.push(tokens[3].to_i32 - 1);
        end
      end

      res = Mesh.new
      res.add_verticies(verticies, indicies)
      return res
    end
  end
end
