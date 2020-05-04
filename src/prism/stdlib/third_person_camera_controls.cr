require "crash"

module Prism
  # TODO: can't we come up with a better name? Or just put it in a namespace.
  # CameraControls::ThirdPerson
  # We may want to put this in the core as well.
  #
  # This provides third person view and controls to the camera.
  # The `Camera` will be positioned view it's attached `Entity` from the third person.
  class ThirdPersonCameraControls < CameraControls
    MIN_ZOOM = 0f32
    MAX_ZOOM = 100f32
    include Prism::InputReceiver
    include Prism::Adapter::GLFW
    @camera_transform : Prism::Transform = Prism::Transform.new
    @distance_from_entity : Float32 = 50
    @angle_around_entity : Float32 = 0
    @pitch : Float32 = 20
    @prev_mouse_position : RenderLoop::Position | Nil = nil

    def input!(tick : RenderLoop::Tick, input : RenderLoop::Input, entity : Crash::Entity)
      calculate_zoom input
      calculate_pitch input
      calculate_angle input
      @prev_mouse_position = input.get_mouse_position

      # camera = entity.get(Prism::Camera).as(Prism::Camera)
      transform = entity.get(Prism::Transform).as(Prism::Transform)
      vertical_distance = calculate_vertical_distance
      horizontal_distance = calculate_horizontal_distance
      calculate_camera_position(horizontal_distance, vertical_distance, transform)
    end

    # TODO: this works but it a little buggy.
    #  The camera has a slight tilt to it and it appears a little lopsided.
    # TODO: limit range of pitch
    # TODO: limit range of zoom
    private def calculate_camera_position(horizontal_distance : Float32, vertical_distance : Float32, entity_transform : Prism::Transform)
      @camera_transform = Prism::Transform.new
      theta : Float32 = entity_transform.rot.y.to_f32 + @angle_around_entity
      offset_x = horizontal_distance * Math.sin(Prism::Maths.to_rad(theta))
      offset_z = horizontal_distance * Math.cos(Prism::Maths.to_rad(theta))
      @camera_transform.pos.x = entity_transform.pos.x - offset_x
      @camera_transform.pos.z = entity_transform.pos.z - offset_z
      @camera_transform.pos.y = entity_transform.pos.y + vertical_distance
      # TODO: this is not exactly want we want. We want the camera to follow behind the entity.
      #  Simply turning to look at it is probably were we are getting the visual bugs.
      rot = @camera_transform.get_look_at_direction(entity_transform.pos, Vector3f.new(0, 1, 0))
      @camera_transform.rot = rot
    end

    private def calculate_horizontal_distance
      @distance_from_entity * Math.cos(Prism::Maths.to_rad(@pitch))
    end

    private def calculate_vertical_distance
      @distance_from_entity * Math.sin(Prism::Maths.to_rad(@pitch))
    end

    private def calculate_zoom(input : RenderLoop::Input)
      offset = input.get_scroll_offset
      zoom_level = offset[:y].to_f32 * 2f32
      @distance_from_entity -= zoom_level
      if @distance_from_entity < MIN_ZOOM
        @distance_from_entity = MIN_ZOOM
      end
      if @distance_from_entity > MAX_ZOOM
        @distance_from_entity = MAX_ZOOM
      end
    end

    private def calculate_pitch(input : RenderLoop::Input)
      if input.get_mouse(Window::MouseButton::Right)
        if position = @prev_mouse_position
          delta = input.get_mouse_position[:y] - position[:y]
          pitch_change = delta * 0.1f32
          @pitch -= pitch_change
        end
      end
      # puts "pitch #{@pitch}"
    end

    private def calculate_angle(input : RenderLoop::Input)
      if input.get_mouse(Window::MouseButton::Left)
        if position = @prev_mouse_position
          delta = input.get_mouse_position[:x] - position[:x]
          angle_change = delta * 0.3f32
          @angle_around_entity -= angle_change
        end
      end
    end
  end
end
