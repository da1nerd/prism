module Prism

  abstract class GameComponent

    abstract def input(transform : Transform, delta : Float32)

    abstract def update(transform : Transform, delta : Float32)

    abstract def render(transform : Transform, shader : Shader)

  end

end
