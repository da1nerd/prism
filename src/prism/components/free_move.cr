require "./game_component.cr"

module Prism
  class FreeMove < GameComponent
    def initialize(speed : Float32)
      initialize(speed, Input::KEY_W, Input::KEY_S, Input::KEY_A, Input::KEY_D)
    end

    def initialize(@speed : Float32, @forward_key : Int32, @back_key : Int32, @left_key : Int32, @right_key : Int32)
    end

    def input(delta : Float32, input : Input)
      mov_amt = @speed * delta

      if input.get_key(@forward_key)
        move(self.transform.rot.forward, mov_amt)
      end
      if input.get_key(@back_key)
        move(self.transform.rot.forward, -mov_amt)
      end
      if input.get_key(@left_key)
        move(self.transform.rot.left, mov_amt)
      end
      if input.get_key(@right_key)
        move(self.transform.rot.right, mov_amt)
      end
    end

    # moves the camera
    def move(direction : Vector3f, amount : Float32)
      self.transform.pos = self.transform.pos + direction * amount
    end
  end
end
