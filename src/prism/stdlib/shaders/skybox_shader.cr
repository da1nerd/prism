module Prism
  # A generic shader for the GUI
  class SkyboxShader < Prism::DefaultShader
    ROTATE_SPEED = 1f32

    uniform "cubeMap", Prism::TextureCubeMap
    uniform "cubeMap2", Prism::TextureCubeMap
    uniform "blendFactor", Float32
    uniform "projectionMatrix", Prism::Maths::Matrix4f
    uniform "fogColor", Prism::Maths::Vector3f

    @rotation : Float32 = 0

    # Increase the skybox rotation each tick
    def tick(tick : RenderLoop::Tick)
      @rotation += ROTATE_SPEED * tick.frame_time.to_f32
    end

    # Binds the view matrix to the shader.
    # TRICKY: this disables the translation so that the view is always centered acround the camera.
    def view_matrix=(matrix : Matrix4f)
      m = matrix.m
      m.[]=(0, 3, 0f32)
      m.[]=(1, 3, 0f32)
      m.[]=(2, 3, 0f32)
      rot_matrix = Quaternion.new(Vector3f.new(0, 1, 0), Maths.to_rad(@rotation)).conjugate.to_rotation_matrix
      set_uniform("viewMatrix", Matrix4f.new(m) * rot_matrix)
    end

    def initialize
      super("skybox")
    end
  end
end
