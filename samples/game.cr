require "lib_gl"
require "../src/prism"
require "./look_at_component.cr"

include Prism

class TestGame < Prism::Game
  SPOT_WIDTH = 1f32
  SPOT_LENGTH = 1f32
  SPOT_HEIGHT = 1f32

  @level : Bitmap?

  def init

    level = Bitmap.new("level0.png").flip_y

    vertices = [] of Vertex
    indices = [] of LibGL::Int

    # build level texture
    0.upto(level.width - 1) do |i|
      0.upto(level.height - 1) do |j|

        if level.pixel(i, j).black?
          next
        end

        x_higher = 1f32
        x_lower = 0f32
        y_higher = 1f32
        y_lower = 0f32

        # generate floor
        indices.push(vertices.size + 2)
        indices.push(vertices.size + 1)
        indices.push(vertices.size + 0)
        indices.push(vertices.size + 3)
        indices.push(vertices.size + 2)
        indices.push(vertices.size + 0)

        vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, 0, j * SPOT_LENGTH), Vector2f.new(x_lower, y_lower)))
        vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, 0, j * SPOT_LENGTH), Vector2f.new(x_higher, y_lower)))
        vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, 0, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_higher)))
        vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, 0, (j + 1) * SPOT_LENGTH), Vector2f.new(x_lower, y_higher)))

        # generate ceiling
        indices.push(vertices.size + 0)
        indices.push(vertices.size + 1)
        indices.push(vertices.size + 2)
        indices.push(vertices.size + 0)
        indices.push(vertices.size + 2)
        indices.push(vertices.size + 3)

        vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, SPOT_HEIGHT, j * SPOT_LENGTH), Vector2f.new(x_lower, y_lower)))
        vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, SPOT_HEIGHT, j * SPOT_LENGTH), Vector2f.new(x_higher, y_lower)))
        vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, SPOT_HEIGHT, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_higher)))
        vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, SPOT_HEIGHT, (j + 1) * SPOT_LENGTH), Vector2f.new(x_lower, y_higher)))

        # generate walls

        if level.pixel(i, j - 1).black?
          indices.push(vertices.size + 0)
          indices.push(vertices.size + 1)
          indices.push(vertices.size + 2)
          indices.push(vertices.size + 0)
          indices.push(vertices.size + 2)
          indices.push(vertices.size + 3)

          vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, 0, j * SPOT_LENGTH), Vector2f.new(x_lower, y_lower)))
          vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, 0, j * SPOT_LENGTH), Vector2f.new(x_higher, y_lower)))
          vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, SPOT_HEIGHT, j * SPOT_LENGTH), Vector2f.new(x_higher, y_higher)))
          vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, SPOT_HEIGHT, j * SPOT_LENGTH), Vector2f.new(x_lower, y_higher)))

        end

        if level.pixel(i, j + 1).black?
          indices.push(vertices.size + 2)
          indices.push(vertices.size + 1)
          indices.push(vertices.size + 0)
          indices.push(vertices.size + 3)
          indices.push(vertices.size + 2)
          indices.push(vertices.size + 0)

          vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, 0, (j + 1) * SPOT_LENGTH), Vector2f.new(x_lower, y_lower)))
          vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, 0, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_lower)))
          vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, SPOT_HEIGHT, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_higher)))
          vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, SPOT_HEIGHT, (j + 1) * SPOT_LENGTH), Vector2f.new(x_lower, y_higher)))
        end

        if level.pixel(i - 1, j).black?
          indices.push(vertices.size + 2)
          indices.push(vertices.size + 1)
          indices.push(vertices.size + 0)
          indices.push(vertices.size + 3)
          indices.push(vertices.size + 2)
          indices.push(vertices.size + 0)

          vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, 0, j * SPOT_LENGTH), Vector2f.new(x_lower, y_lower)))
          vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, 0, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_lower)))
          vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, SPOT_HEIGHT, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_higher)))
          vertices.push(Vertex.new(Vector3f.new(i * SPOT_WIDTH, SPOT_HEIGHT, j * SPOT_LENGTH), Vector2f.new(x_lower, y_higher)))

        end

        if level.pixel(i + 1, j).black?
          indices.push(vertices.size + 0)
          indices.push(vertices.size + 1)
          indices.push(vertices.size + 2)
          indices.push(vertices.size + 0)
          indices.push(vertices.size + 2)
          indices.push(vertices.size + 3)

          vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, 0, j * SPOT_LENGTH), Vector2f.new(x_lower, y_lower)))
          vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, 0, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_lower)))
          vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, SPOT_HEIGHT, (j + 1) * SPOT_LENGTH), Vector2f.new(x_higher, y_higher)))
          vertices.push(Vertex.new(Vector3f.new((i + 1) * SPOT_WIDTH, SPOT_HEIGHT, j * SPOT_LENGTH), Vector2f.new(x_lower, y_higher)))

        end
      end
    end

    # field_depth = 10.0f32
    # field_width = 10.0f32

    # verticies = [
    #   ,Vertex.new(Vector3f.new(-field_width, 0, -field_depth), Vector2f.new(0, 0))
    #   Vertex.new(Vector3f.new(-field_width, 0, field_depth * 3), Vector2f.new(0, 1)),
    #   Vertex.new(Vector3f.new(field_width * 3, 0, -field_depth), Vector2f.new(1, 0)),
    #   Vertex.new(Vector3f.new(field_width * 3, 0, field_depth * 3), Vector2f.new(1, 1))
    # ]

    # indicies = Array(LibGL::Int) {
    #   0, 1, 2,
    #   2, 1, 3
    # }

    # verticies2 = [
    #   Vertex.new(Vector3f.new(-field_width/10.0f32, 0, -field_depth/10.0f32), Vector2f.new(0, 0)),
    #   Vertex.new(Vector3f.new(-field_width/10.0f32, 0, field_depth/10.0f32 * 3), Vector2f.new(0, 1)),
    #   Vertex.new(Vector3f.new(field_width/10.0f32 * 3, 0, -field_depth/10.0f32), Vector2f.new(1, 0)),
    #   Vertex.new(Vector3f.new(field_width/10.0f32 * 3, 0, field_depth/10.0f32 * 3), Vector2f.new(1, 1))
    # ]

    # indicies2 = Array(LibGL::Int) {
    #   0, 1, 2,
    #   2, 1, 3
    # }

    # mesh2 = Mesh.new(verticies2, indicies2, true);

    mesh = Mesh.new(vertices, indices, true);
    material = Material.new()
    material.add_texture("diffuse", Texture.new("bricks.jpg"))
    material.add_float("specularIntensity", 1)
    material.add_float("specularPower", 8)

    # material2 = Material.new()
    # material2.add_texture("diffuse", Texture.new("test.png"))
    # material2.add_float("specularIntensity", 1)
    # material2.add_float("specularPower", 8)

    # temp_mesh = Mesh.new("monkey3.obj")

    mesh_renderer = MeshRenderer.new(mesh, material)

    plane_object = GameObject.new
    plane_object.add_component(mesh_renderer)
    plane_object.transform.pos.set(0, -1, 5)

    directional_light_object = GameObject.new()
    directional_light = DirectionalLight.new(Vector3f.new(1,1,1), 0.4)
    directional_light_object.add_component(directional_light)

    directional_light.transform.rot = Quaternion.new(Vector3f.new(1f32, 0f32, 0f32), Prism.to_rad(-45f32))

    # point_light_object = GameObject.new()
    # point_light = PointLight.new(Vector3f.new(0.0f32, 1.0f32, 0.0f32), 0.4f32, Attenuation.new(0.0f32, 0.0f32, 1.0f32))
    # point_light_object.add_component(point_light)

    # spot_light_object = GameObject.new()
    # spot_light = SpotLight.new(
    #   Vector3f.new(0.0f32, 1.0f32, 1.0f32),
    #   0.4f32,
    #   Attenuation.new(0.0f32, 0.0f32, 0.1f32),
    #   0.7f32)
    # spot_light_object.add_component(spot_light)

    # spot_light_object.transform.pos.set(5, 0, 5)
    # spot_light_object.transform.rot = Quaternion.new(Vector3f.new(0.0f32, 1.0f32, 0.0f32), Prism.to_rad(90.0f32))
    camera = GameObject.new().add_component(FreeLook.new(0.5)).add_component(FreeMove.new(10.0)).add_component(Camera.new(Prism.to_rad(70.0f32), 800f32/600f32, 0.01f32, 1000.0f32))


    add_object(directional_light_object)
    add_object(plane_object)
    add_object(camera)
    # add_object(point_light_object)
    # add_object(spot_light_object)

    # test_mesh1 = GameObject.new().add_component(MeshRenderer.new(mesh2, material))
    # test_mesh2 = GameObject.new().add_component(MeshRenderer.new(mesh2, material))
    # test_mesh3 = GameObject.new().add_component(LookAtComponent.new).add_component(MeshRenderer.new(temp_mesh, material))

    # test_mesh1.transform.pos.set(0f32, 2f32, 0f32)
    # test_mesh1.transform.rot = Quaternion.new(Vector3f.new(0f32, 1f32, 0f32), 0.4f32)
    # test_mesh2.transform.pos.set(0f32, 0f32, 5f32)

    # test_mesh1.add_child(test_mesh2)
    # test_mesh2.add_child(GameObject.new().add_component(FreeLook.new(0.5)).add_component(FreeMove.new(10.0)).add_component(Camera.new(Prism.to_rad(70.0f32), 800f32/600f32, 0.01f32, 1000.0f32)))

    # add_object(test_mesh1)
    # add_object(test_mesh3)

    # test_mesh3.transform.pos.set(5,5,5)
    # test_mesh3.transform.rot.set(Quaternion.new(Vector3f.new(0,1,0), Prism.to_rad(20)))

    # add_object(GameObject.new().add_component(MeshRenderer.new(Mesh.new("monkey3.obj"), material2)))

  end
end
