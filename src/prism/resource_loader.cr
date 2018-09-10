require "./vector3f"
require "./mesh"
require "./vertex"
require "./texture"
require "lib_gl"

module Prism
  class ResourceLoader

    def self.load_texture(file_name : String) : Texture
      ext = File.extname(file_name)

      # read data
      path = File.join(File.dirname(PROGRAM_NAME), "/res/textures/", file_name)
      data = File.read(path)

      # create texture
      LibGL.gen_textures 1, out id

      # generate texture
      # use this to load png https://github.com/stumpycr/stumpy_png
      # https://github.com/nya-engine/nya/blob/585ae659542590edb500646e22ba428e9684fa8a/src/nya/render/texture.cr#L15
      # see https://github.com/nya-engine/nya/blob/585ae659542590edb500646e22ba428e9684fa8a/src/nya/render/backends/gl.cr#L157
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_MIN_FILTER, LibGL::LINEAR)
      LibGL.tex_parameter_i(LibGL::TEXTURE_2D, LibGL::TEXTURE_MAG_FILTER, LibGL::LINEAR)
      LibGL.tex_image_2d(LibGL::TEXTURE_2D, 0, LibGL::RGB, 512, 512, 0, LibGL::RGB, LibGL::UNSIGNED_BYTE, data)
      LibGL.generate_mipmap(LibGL::TEXTURE_2D)

      Texture.new(id)
    end

    # Loads a shader from the disk
    def self.load_shader(file_name : String) : String
      path = File.join(File.dirname(PROGRAM_NAME), "/res/shaders/", file_name)
      return File.read(path)
    end

    # Loads a mesh from the disk
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

      res = Mesh.new
      res.add_verticies(verticies, indicies)
      return res
    end
  end
end
