module Prism

  abstract class GameComponent

    abstract def init
    abstract def input
    abstract def update

    abstract def render

  end

end
