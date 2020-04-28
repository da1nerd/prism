require "annotation"
require "./component.cr"

module Prism
  class Camera < Prism::Component
    @projection : Maths::Matrix4f
    @sync_aspect_ratio : Bool

    # Creates a camera with default values
    def initialize
      field_of_view = Angle.from_degrees(60)
      aspect_ratio : Float32 = 1f32 / 1f32
      initialize(field_of_view, aspect_ratio, 0.01f32, 1000f32)
    end

    # Controls whether or not the camera should automatically sync
    # it's aspect ratio with the window size.
    def sync_aspect_ratio=(@sync_aspect_ratio : Bool)
    end

    def input(tick : RenderLoop::Tick, input : RenderLoop::Input)
      # keep the aspect ratio in sync with the window
      if @sync_aspect_ratio
        size = input.window_size
        self.aspect = (size[:width] / size[:height]).to_f32
      end
    end

    def initialize(@fov : Angle, @aspect : Float32, @z_near : Float32, @z_far : Float32)
      @sync_aspect_ratio = true
      @projection = Matrix4f.new.init_perspective(@fov.radians, @aspect, @z_near, @z_far)
    end

    # changes the aspect ratio
    def aspect=(aspect_ratio : Float32)
      @aspect = aspect_ratio
      @projection = Matrix4f.new.init_perspective(@fov.radians, @aspect, @z_near, @z_far)
    end

    # Returns the projection matrix.
    # This represents the projection of entities on the screen.
    # In other words, things get bigger or smaller as they get closing to the screen or farther away.
    def get_projection : Matrix4f
      @projection
    end
  end
end
