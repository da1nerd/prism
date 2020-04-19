module Prism::EntitySystem
  #
  abstract class System
    abstract def update(time : Float32)
  end
end
