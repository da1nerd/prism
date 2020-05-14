require "annotation"
require "crash"
require "../shader"

module Prism
  # Produces an attenuated point of light.
  # The light will attach to the position of it's entity.
  class PointLight < Crash::Component
    include Prism::Shader::UniformStruct
    include Prism::InputReceiver

    @[Field]
    @position : Vector3f

    @[Field]
    @color : Vector3f

    @[Field]
    @attenuation : Prism::Attenuation

    property color
    getter position

    # Creates a new light.
    # The light will automatically follow the position of the entity.
    # But you must add an `InputSubscriber` component to your entity in order for this to work.
    # TODO: it would be nice to not have to add the subscriber component to the entity.
    def initialize(@color)
      @position = Vector3f.new(0, 0, 0)
      @attenuation = Prism::Attenuation.new(1, 0, 0)
    end

    def initialize(@color, @attenuation : Prism::Attenuation)
      @position = Vector3f.new(0, 0, 0)
    end

    def attenuation : Prism::Attenuation
      @attenuation
    end

    def attenuation=(@attenuation : Prism::Attenuation)
    end

    @[Override]
    def input!(tick : RenderLoop::Tick, input : RenderLoop::Input, entity : Crash::Entity)
      # follow the entity
      @position = entity.get(Prism::Transform).as(Prism::Transform).pos.clone
    end
  end
end
