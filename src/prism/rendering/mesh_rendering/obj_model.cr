require "../../core/vector3f"
require "../../core/vector2f"
require "./obj_index"


module Prism

  class OBJModel

    @positions : Array(Vector3f)
    @tex_coords : Array(Vector2f)
    @normals : Array(Vector3f)
    @indicies : Array(OBJIndex)
    @has_tex_coords : Bool
    @has_normals : Bool

    getter positions, tex_coords, normals, indicies

    def initialize(file_name : String)
      @positions = [] of Vector3f
      @tex_coords = [] of Vector2f
      @normals = [] of Vector3f
      @indicies = [] of OBJIndex
      @has_tex_coords = false
      @has_normals = false

      File.each_line(file_name) do |line|
        tokens = line.split(" ", remove_empty: true)
        if tokens.size === 0 || tokens[0] === "#"
          next
        elsif tokens[0] === "v"
          # verticies
          @positions.push(Vector3f.new(tokens[1].to_f32, tokens[2].to_f32, tokens[3].to_f32))
        elsif tokens[0] === "vt"
          # vertex textures
          @tex_coords.push(Vector2f.new(tokens[1].to_f32, tokens[2].to_f32))
        elsif tokens[0] === "vn"
          # vertex normals
          @normals.push(Vector3f.new(tokens[1].to_f32, tokens[2].to_f32, tokens[3].to_f32))
        elsif tokens[0] === "f"
          # faces
          0.upto(tokens.size - 4) do |i|
            @indicies.push(parse_obj_index(tokens[1 ]))
            @indicies.push(parse_obj_index(tokens[2 + i]))
            @indicies.push(parse_obj_index(tokens[3 + i]))
          end
        end
      end
    end

    private def parse_obj_index(token : String) : OBJIndex
      values = token.split("/")

      result =  OBJIndex.new
      result.vertex_index = values[0].to_i32 - 1

      if values.size > 1
        @has_tex_coords = true
        result.tex_coord_index = values[1].to_i32 - 1

        if values.size > 2
          @has_normals = true
          result.normal_index = values[2].to_i32 - 1
        end
      end

      return result
    end

  end

end
