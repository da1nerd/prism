require "lib_gl"
require "../prism/core/input"
require "../prism/rendering/mesh"
require "../prism/rendering/vertex"
require "../prism/core/vector3f"
require "../prism/rendering/phong_shader"
require "../prism/rendering/basic_shader"
require "../prism/core/timer"
require "../prism/core/transform"
require "../prism/rendering/camera"
require "../prism/rendering/spot_light"
require "../src/game/game"

module Prism

  # TODO: make this an abstract class
  class TestGame < Game

    @camera : Camera?
    @transform : Transform?
    @temp : Float32 = 0.0f32

    @plight1 = PointLight.new(BaseLight.new(Vector3f.new(1,0.5,0), 0.8), Attenuation.new(0, 0, 1), Vector3f.new(-2, 0, 5), 10)
    @plight2 = PointLight.new(BaseLight.new(Vector3f.new(0,0.5,1), 0.8), Attenuation.new(0, 0, 1), Vector3f.new(2, 0, 7), 10)

    @slight1 = SpotLight.new(PointLight.new(BaseLight.new(Vector3f.new(0,1,1), 0.8), Attenuation.new(0, 0, 0.1), Vector3f.new(-2, 0, 5), 30), Vector3f.new(1,1,1), 0.7)

    def initialize(@width : Float32, @height : Float32)
    end

    def init
      @material = Material.new(Texture.new("test.png"), Vector3f.new(1,1,1), 1, 8);
      @shader = PhongShader.new
      camera = Camera.new
      transform = Transform.new(camera)
      @camera = camera
      @transform = transform

      field_depth = 10.0f32
      field_width = 10.0f32

      verticies = [
        Vertex.new(Vector3f.new(-field_width, 0, -field_depth), Vector2f.new(0, 0)),
        Vertex.new(Vector3f.new(-field_width, 0, field_depth * 3), Vector2f.new(0, 1)),
        Vertex.new(Vector3f.new(field_width * 3, 0, -field_depth), Vector2f.new(1, 0)),
        Vertex.new(Vector3f.new(field_width * 3, 0, field_depth * 3), Vector2f.new(1, 1))
      ]

      indicies = Array(LibGL::Int) {
        0, 1, 2,
        2, 1, 3
      }

      @mesh = Mesh.new(verticies, indicies, true);

      transform.set_projection(70f32, @width, @height, 0.1f32, 1_000f32)

      PhongShader.ambient_light = Vector3f.new(0.1, 0.1, 0.1)
      PhongShader.directional_light = DirectionalLight.new(BaseLight.new(Vector3f.new(1,1,1), 0.18), Vector3f.new(1,1,1))
      PhongShader.point_lights = [@plight1, @plight2]
      PhongShader.spot_lights = [@slight1]
    end

    # Processes input during a frame
    def input(input : Input)
      keys = input.get_any_key_down
      if keys.size > 0
        puts "Pressed keys #{keys}"
      end
      if camera = @camera
        camera.input(input)
      end
      # if input.get_key_down(Input::KEY_UP)
      #   puts "We've just pressed up"
      # end
      # if input.get_key_up(Input::KEY_UP)
      #   puts "We've just released up"
      # end
      #
      # if input.get_mouse_down(0)
      #   puts "We've just left clicked at #{input.get_mouse_position.to_string}"
      # end
      # if input.get_mouse_up(0)
      #   puts "We've just released the left mouse button"
      # end

    end

    def update
      delta = Timer.get_delta

      if delta
        @temp += delta
      end

      sinTemp = Math.sin(@temp)
      camera = @camera

      if transform = @transform
        transform.translation(0, -1, 5)
        # @transform.rotation(0, 180 *sinTemp, 0)
      end

      if plight1 = @plight1
        plight1.position = Vector3f.new(3, 0, 8 * (Math.sin(@temp) + 1.0/2.0) + 10)
      end
      if plight2 = @plight2
        plight2.position = Vector3f.new(7, 0, 8 * (Math.cos(@temp) + 1.0/2.0) + 10)
      end

      if slight1 = @slight1
        if camera
          slight1.point_light.position = camera.pos
          slight1.direction = camera.forward
        end
      end

      # @transform.scale(0.7f32 * sinTemp, 0.7f32 * sinTemp, 0.7f32 * sinTemp)
    end

    def render
      camera = @camera
      shader = @shader
      mesh = @mesh
      transform = @transform
      material = @material

      if camera && shader && mesh && transform && material
        RenderUtil.set_clear_color((camera.pos / 1024).abs)
        shader.bind
        shader.update_uniforms(transform.get_transformation, transform.get_projected_transformation, material, camera.pos)
        mesh.draw
      end
    end

  end

end
