module Prism::OBJ
  extend self

  def load(file_name : String) : OBJ::ModelData
    vertices = [] of OBJ::Vertex
    textures = [] of Vector2f
    normals = [] of Vector3f
    indices = [] of Int32
    lines = File.read_lines(file_name).each
    line : String | Iterator::Stop

    while true
      # TRICKY: the first lines should always be as string
      line = lines.next.as(String)
      if line.starts_with? "v "
        current_line = line.split(" ")
        position = Vector3f.new(
          current_line[1].to_f32,
          current_line[2].to_f32,
          current_line[3].to_f32
        )
        vertices << Vertex.new(vertices.size, position)
      elsif line.starts_with? "vt "
        current_line = line.split(" ")
        textures << Vector2f.new(
          current_line[1].to_f32,
          current_line[2].to_f32,
        )
      elsif line.starts_with? "vn "
        current_line = line.split(" ")
        normals << Vector3f.new(
          current_line[1].to_f32,
          current_line[2].to_f32,
          current_line[3].to_f32
        )
      elsif line.starts_with? "f "
        break
      end
    end

    while !line.is_a?(Iterator::Stop) && line.as(String).starts_with?("f ")
      current_line = line.as(String).split(" ")
      vertex1 = current_line[1].split("/")
      vertex2 = current_line[2].split("/")
      vertex3 = current_line[3].split("/")
      process_vertex(vertex1, vertices, indices)
      process_vertex(vertex2, vertices, indices)
      process_vertex(vertex3, vertices, indices)
      line = lines.next
    end

    remove_unused_vertices vertices
    vertices_array = Array(Float32).new(vertices.size * 3, 0)
    textures_array = Array(Float32).new(vertices.size * 2, 0)
    normals_array = Array(Float32).new(vertices.size * 3, 0)
    furthest = convert_data_to_arrays(vertices, textures, normals, vertices_array, textures_array, normals_array)
    OBJ::ModelData.new(vertices_array, textures_array, normals_array, indices, furthest)
  end

  private def process_vertex(vertex : Array(String), vertices : Array(OBJ::Vertex), indices : Array(Int32))
    index = vertex[0].to_i32 - 1
    current_vertex = vertices[index]
    texture_index = vertex[1].to_i32 - 1
    normal_index = vertex[2].to_i32 - 1
    if !current_vertex.is_set?
      current_vertex.texture_index = texture_index
      current_vertex.normal_index = normal_index
      indices << index
    else
      deal_with_already_processed_vertex(current_vertex, texture_index, normal_index, indices, vertices)
    end
  end

  private def convert_data_to_arrays(vertices : Array(OBJ::Vertex), textures : Array(Vector2f), normals : Array(Vector3f), vertices_array : Array(Float32), textures_array : Array(Float32), normals_array : Array(Float32)) : Float32
    furthest_point : Float32 = 0

    0.upto(vertices.size - 1) do |i|
      current_vertex = vertices[i]
      if current_vertex.length > furthest_point
        furthest_point = current_vertex.length
      end
      position = current_vertex.position
      texture_coord = textures[current_vertex.texture_index]
      normal_vector = normals[current_vertex.normal_index]
      vertices_array[i * 3] = position.x
      vertices_array[i * 3 + 1] = position.y
      vertices_array[i * 3 + 2] = position.z
      textures_array[i * 2] = texture_coord.x
      textures_array[i * 2 + 1] = texture_coord.y
      normals_array[i * 3] = normal_vector.x
      normals_array[i * 3 + 1] = normal_vector.y
      normals_array[i * 3 + 2] = normal_vector.z
    end

    return furthest_point
  end

  private def remove_unused_vertices(vertices : Array(OBJ::Vertex))
    vertices.each do |vertex|
      if !vertex.is_set?
        vertex.texture_index = 0
        vertex.normal_index = 0
      end
    end
  end

  private def deal_with_already_processed_vertex(previous_vertex : OBJ::Vertex, new_texture_index : Int32, new_normal_index : Int32, indices : Array(Int32), vertices : Array(OBJ::Vertex))
    if previous_vertex.has_same_texture_and_normal?(new_texture_index, new_normal_index)
      indices << previous_vertex.index
    else
      another_vertex = previous_vertex.duplicate_vertex
      if another_vertex
        deal_with_already_processed_vertex(another_vertex.as(OBJ::Vertex), new_texture_index, new_normal_index, indices, vertices)
      else
        duplicate_vertex = Vertex.new(vertices.size, previous_vertex.position)
        duplicate_vertex.texture_index = new_texture_index
        duplicate_vertex.normal_index = new_normal_index
        previous_vertex.duplicate_vertex = duplicate_vertex
        vertices << duplicate_vertex
        indices << duplicate_vertex.index
      end
    end
  end
end
