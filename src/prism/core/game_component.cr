module Prism

  abstract class GameComponent

    abstract def input(transform : Transform)

    abstract def update(transform : Transform)

    abstract def render(transform : Transform, shader : Shader)

  end

end
