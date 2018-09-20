require "lib_gl"
require "../../prism"

module Prism

  class RenderingEngine

    @main_camera : Camera
    @ambient_light : Vector3f
    # @directional_light2 : DirectionalLight
    # @point_light_list : Array(PointLight)

    @spot_lights : Array(SpotLight)



    @active_directional_light : DirectionalLight
    @active_point_light : PointLight
    @active_spot_light : SpotLight

    getter main_camera, ambient_light
    setter main_camera, active_light

    # "Permanent" Structures
    @directional_lights : Array(DirectionalLight)
    @point_lights : Array(PointLight)

    @lights : Array(BaseLight)
    @active_light : BaseLight

    def initialize(window : CrystGLUT::Window)
      @lights = [] of BaseLight
      @directional_lights = [] of DirectionalLight
      @point_lights = [] of PointLight
      @spot_lights = [] of SpotLight

      LibGL.clear_color(0.0f32, 0.0f32, 0.0f32, 0.0f32)

      LibGL.front_face(LibGL::CW)
      LibGL.cull_face(LibGL::BACK)
      LibGL.enable(LibGL::CULL_FACE)
      LibGL.enable(LibGL::DEPTH_TEST)

      LibGL.enable(LibGL::DEPTH_CLAMP)

      LibGL.enable(LibGL::TEXTURE_2D)

      @main_camera = Camera.new(to_rad(70.0), window.get_width.to_f32/window.get_height.to_f32, 0.01f32, 1000.0f32)
      @ambient_light = Vector3f.new(0.1, 0.1, 0.1)

      # default values
      @active_directional_light = DirectionalLight.new(BaseLight.new(Vector3f.new(0,0,1), 0.4), Vector3f.new(1,1,1))
      # @directional_light2 = DirectionalLight.new(BaseLight.new(Vector3f.new(1,0,0), 0.4), Vector3f.new(-1,1,-1))
      #
      # @point_light_list = [] of PointLight
      # light_field_width = 5
      # light_field_depth = 5
      # light_field_start_x = 0.0f32
      # light_field_start_y = 0.0f32
      # light_field_step_x = 7.0f32
      # light_field_step_y = 7.0f32
      #
      # 0.upto(light_field_width - 1) do |r|
      #   0.upto(light_field_depth -1) do |c|
      #     @point_light_list.push(PointLight.new(
      #                             BaseLight.new(Vector3f.new(0,1,0), 0.4),
      #                             Attenuation.new(0,0,1),
      #                             Vector3f.new(light_field_start_x + light_field_step_x * r, 0, light_field_start_y + light_field_step_y * c),
      #                             100.0))
      #   end
      # end
      #
      @active_point_light = PointLight.new(BaseLight.new(Vector3f.new(0,1,0), 0.4), Attenuation.new(0,0,1), Vector3f.new(5, 0, 5), 100.0)
      @active_spot_light = SpotLight.new(
                      PointLight.new(
                        BaseLight.new(Vector3f.new(0,1,1), 0.4),
                        Attenuation.new(0,0,0.1),
                        Vector3f.new(7, 0, 7),
                        100.0
                      ),
                      Vector3f.new(1,0,0), 0.7)
    end

    def render(object : GameObject)
      clear_screen
      @lights.clear
      object.add_to_rendering_engine(self)

      forward_ambient = ForwardAmbient.instance
      forward_directional = ForwardDirectional.instance
      forward_point = ForwardPoint.instance
      forward_spot = ForwardSpot.instance
      forward_ambient.rendering_engine = self
      forward_directional.rendering_engine = self
      forward_point.rendering_engine = self
      forward_spot.rendering_engine = self

      object.render(forward_ambient)

      LibGL.enable(LibGL::BLEND)
      LibGL.blend_func(LibGL::ONE, LibGL::ONE)
      LibGL.depth_mask(LibGL::FALSE)
      LibGL.depth_func(LibGL::EQUAL)

      0.upto(@lights.size - 1) do |i|
        light = @lights[i]
        if shader = light.shader
          shader.set_rendering_engine(self)

          @active_light = light

          object.render(shader)
        end
      end

      # 0.upto(@directional_lights.size - 1) do |i|
      #   @active_directional_light = @directional_lights[i]
      #   object.render(forward_directional)
      # end
      #
      # 0.upto(@point_lights.size - 1) do |i|
      #   @active_point_light = @point_lights[i]
      #   object.render(forward_point)
      # end
      #
      # 0.upto(@spot_lights.size - 1) do |i|
      #   @active_spot_light = @spot_lights[i]
      #   object.render(forward_spot)
      # end

      LibGL.depth_func(LibGL::LESS)
      LibGL.depth_mask(LibGL::TRUE)
      LibGL.disable(LibGL::BLEND)
    end

    # private def clear_light_list
    #   @directional_lights.clear
    #   @point_lights.clear
    #   @spot_lights.clear
    # end

    # def add_directional_light(light : DirectionalLight)
    #   @directional_lights.push(light)
    # end
    #
    # def add_point_light(light : PointLight)
    #   @point_lights.push(light)
    # end
    #
    # def add_spot_light(light : SpotLight)
    #   @spot_lights.push(light)
    # end
    #
    def add_light(light : BaseLight)
      @lights.push(light)
    end

    # temporary hack
    def input(delta : Float32, input : Input)
      @main_camera.input(delta, input)
    end

    private def clear_screen
      # TODO: stencil buffer
      LibGL.clear(LibGL::COLOR_BUFFER_BIT | LibGL::DEPTH_BUFFER_BIT)
    end

    # Enable/disables textures
    private def set_textures(enabled : Boolean)
      if enabled
        LibGL.enable(LibGL::TEXTURE_2D)
      else
        LibGL.disable(LibGL::TEXTURE_2D)
      end
    end

    def flush
      LibGL.flush()
    end

    # Returns which version of OpenGL is available
    def get_open_gl_version
      return String.new(LibGL.get_string(LibGL::VERSION))
    end

    private def set_clear_color(color : Vector3f)
      LibGL.clear_color(color.x, color.y, color.z, 1.0);
    end

    private def unbind_textures
      LibGL.bind_texture(LibGL::TEXTURE_2D, 0)
    end

    def directional_light
      @active_directional_light
    end

    def point_light
      @active_point_light
    end

    def spot_light
      @active_spot_light
    end

  end

end
