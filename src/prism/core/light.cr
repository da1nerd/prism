require "./shader"
require "./component"

module Prism::Core
  class SimpleLight < Component
    include Shader::Serializable

    @[Shader::Field]
    @color : Vector3f
  
    @[Shader::Field]
    @position : Vector3f

    def initialize(@position : Vector3f, @color : Vector3f)
    end
  end

  # Fundamental light component
  abstract class Light < Component
    include Shader::Serializable
    # property shader

    @shader : Shader::ShaderProgram

    def initialize(@shader : Shader::ShaderProgram)
    end

    # Binds an object's *transform* and *material* to the light shader.
    # This should be done just before drawing the object's `Prism::Mesh`
    def on(transform : Transform, material : Material, camera : Camera)
      @shader.start(self.to_uniform, transform, material, camera)
    end

    # Turns off the light
    def off
      @shader.stop
    end

    def add_to_engine(engine : Core::RenderingEngine)
      engine.add_light(self)
    end
  end
end
