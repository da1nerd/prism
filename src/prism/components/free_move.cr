require "./game_component.cr"

module Prism
  class FreeMove < GameComponent

    getter movement
    setter movement

    def initialize(speed : Float32)
      initialize(speed, Input::KEY_W, Input::KEY_S, Input::KEY_A, Input::KEY_D)
    end

    def initialize(@speed : Float32, @forward_key : Int32, @back_key : Int32, @left_key : Int32, @right_key : Int32)
      @movement = Vector3f.new(0, 0, 0)
    end

    def input(delta : Float32, input : Input)
      mov_amt = @speed * delta

      @movement = Vector3f.new(0, 0, 0)

      if input.get_key(@forward_key)
        @movement = get_move(self.transform.rot.forward, mov_amt)
      end
      if input.get_key(@back_key)
        @movement = get_move(self.transform.rot.forward, -mov_amt)
      end
      if input.get_key(@left_key)
        @movement = get_move(self.transform.rot.left, mov_amt)
      end
      if input.get_key(@right_key)
        @movement = get_move(self.transform.rot.right, mov_amt)
      end
    end

    def update(delta : Float32)
      if @movement.length > 0
        self.transform.pos = @movement
      end
    end

    # moves the camera
    def move(direction : Vector3f, amount : Float32)
      self.transform.pos = get_move(direction, amount)
    end

    # Generates the movement vector
    def get_move(direction : Vector3f, amount : Float32)
      return self.transform.pos + direction * amount
    end
  end
end
