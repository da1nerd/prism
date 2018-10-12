module Prism
  module RenderingEngineProtocol
    abstract def render(object)
    abstract def add_light(light)
    abstract def add_camera(camera)
  end
end
