require "crash"

module Prism
  # Causes the parent `Entity`'s position to be controlled by the keyboard.
  class FreeMove < Crash::Component
    include Prism::Adapter::GLFW
    property movement
    @position : Vector3f
    getter position

    def initialize
      initialize(20)
    end

    def initialize(speed : Float32)
      initialize(speed, Window::Key::W, Window::Key::S, Window::Key::A, Window::Key::D)
    end

    def initialize(@speed : Float32, @forward_key : Window::Key, @back_key : Window::Key, @left_key : Window::Key, @right_key : Window::Key)
      @position = Vector3f.new(0, 0, 0)
    end

    def input(tick : RenderLoop::Tick, input : RenderLoop::Input, transform : Prism::Transform)
      mov_amt = @speed * tick.frame_time.to_f32

      movement = Vector3f.new(0, 0, 0)

      if input.get_key(Window::Key::LeftShift)
        mov_amt *= 10
      end
      if input.get_key(@forward_key)
        movement = movement + calculate_move(transform.rot.forward, mov_amt)
      end
      if input.get_key(@back_key)
        movement = movement + calculate_move(transform.rot.forward, -mov_amt)
      end
      if input.get_key(@left_key)
        movement = movement + calculate_move(transform.rot.left, mov_amt)
      end
      if input.get_key(@right_key)
        movement = movement + calculate_move(transform.rot.right, mov_amt)
      end

      @position = transform.pos + movement
    end

    # Generates the movement vector
    private def calculate_move(direction : Vector3f, amount : Float32)
      direction * amount
    end
  end
end
