module Prism

  module RenderingEngineProtocol
    abstract def render(object)
    abstract def add_light(light)
    abstract def input(delta, input)
  end

end
