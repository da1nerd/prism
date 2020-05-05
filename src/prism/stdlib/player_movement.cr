module Prism
  # TODO: we might want to move this into the core.
  #  It will depend on how this class evolves.
  #
  # This adds player like movement to an Entity.
  # You'll be able to control the entity using the keyboard and perform some basic actions.
  class PlayerMovement < Crash::Component
    include Prism::Adapter::GLFW
    include Prism::InputReceiver

    WALK_SPEED =  20f32
    RUN_SPEED  = 100f32
    TURN_SPEED = 160f32
    Y_AXIS     = Vector3f.new(0, 1, 0)
    GRAVITY    = -50.0f32
    JUMP_POWER =    30f32

    @current_speed : Float32 = 0
    @current_turn_speed : Float32 = 0
    @upwards_speed : Float32 = 0
    @is_in_air : Bool = false

    def input!(tick : RenderLoop::Tick, input : RenderLoop::Input, entity : Crash::Entity)
      transform = entity.get(Prism::Transform).as(Prism::Transform)
      # move
      if input.get_key(Window::Key::W)
        @current_speed = input.get_key(Window::Key::LeftShift) ? RUN_SPEED : WALK_SPEED
      elsif input.get_key(Window::Key::S)
        @current_speed = input.get_key(Window::Key::LeftShift) ? -RUN_SPEED : -WALK_SPEED
      else
        @current_speed = 0
      end

      # turn
      if input.get_key(Window::Key::D)
        @current_turn_speed = TURN_SPEED
      elsif input.get_key(Window::Key::A)
        @current_turn_speed = -TURN_SPEED
      else
        @current_turn_speed = 0
      end

      # jump
      if input.get_key(Window::Key::Space) && !@is_in_air
        @upwards_speed = JUMP_POWER
        @is_in_air = true
      end

      turn_amount = @current_turn_speed * tick.frame_time.to_f32
      move_amount = @current_speed * tick.frame_time.to_f32

      transform.rotate(Y_AXIS, Prism::Maths.to_rad(turn_amount))
      transform.pos = transform.pos + transform.rot.forward * move_amount

      # gravity slows jump speed
      @upwards_speed += GRAVITY * tick.frame_time.to_f32
      transform.pos.y += @upwards_speed * tick.frame_time.to_f32
    end

    # Called by the terrain system so we can check the terrain height of the entity.
    # this is a rudimentary form of collision detection.
    def detect_terrain!(entity : Crash::Entity, terrain : Crash::Entity)
      entity_transform = entity.get(Prism::Transform).as(Prism::Transform)
      terrain_component = terrain.get(Prism::Terrain).as(Prism::Terrain)
      terrain_height = terrain_component.height_at(entity_transform.pos)
      if entity_transform.pos.y < terrain_height
        entity_transform.pos.y = terrain_height
        @is_in_air = false
        @upwards_speed = 0
      end
    end
  end
end
