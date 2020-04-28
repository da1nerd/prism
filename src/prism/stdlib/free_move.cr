module Prism
  # Causes the parent `Entity`'s position to be controlled by the keyboard.
  class FreeMove < Prism::Component
    include Prism::Adapter::GLFW
    # TODO: change to property
    getter movement
    setter movement
    @position : Vector3f
    getter position

    def initialize
      initialize(10)
    end

    def initialize(speed : Float32)
      initialize(speed, Window::Key::W, Window::Key::S, Window::Key::A, Window::Key::D)
    end

    def initialize(@speed : Float32, @forward_key : Window::Key, @back_key : Window::Key, @left_key : Window::Key, @right_key : Window::Key)
      @position = Vector3f.new(0, 0, 0)
    end

    def input(tick : RenderLoop::Tick, input : RenderLoop::Input)
      mov_amt = @speed * tick.frame_time.to_f32

      movement = Vector3f.new(0, 0, 0)

      if input.get_key(Window::Key::LeftShift)
        mov_amt *= 10
      end
      if input.get_key(@forward_key)
        movement = movement + calculate_move(self.transform.rot.forward, mov_amt)
      end
      if input.get_key(@back_key)
        movement = movement + calculate_move(self.transform.rot.forward, -mov_amt)
      end
      if input.get_key(@left_key)
        movement = movement + calculate_move(self.transform.rot.left, mov_amt)
      end
      if input.get_key(@right_key)
        movement = movement + calculate_move(self.transform.rot.right, mov_amt)
      end

      @position = calculate_position(movement)

      # propogate position to parent
      # TODO: we shouldn't be modifying the parent directly like this.
      # if @position.length > 0
      #   self.transform.pos = @position
      # end
    end

    # moves the camera
    def move(direction : Vector3f, amount : Float32)
      self.transform.pos = get_move(direction, amount)
    end

    # Generates the movement vector
    private def calculate_move(direction : Vector3f, amount : Float32)
      direction * amount
    end

    # Generates the position fector
    private def calculate_position(move : Vector3f) : Vector3f
      self.transform.pos + move
    end
  end
end
