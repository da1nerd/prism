module Prism::Systems
  class SkyboxRenderer
    SIZE     = 500f32
    VERTICES = [
      -SIZE, SIZE, -SIZE,
      -SIZE, -SIZE, -SIZE,
      SIZE, -SIZE, -SIZE,
      SIZE, -SIZE, -SIZE,
      SIZE, SIZE, -SIZE,
      -SIZE, SIZE, -SIZE,

      -SIZE, -SIZE, SIZE,
      -SIZE, -SIZE, -SIZE,
      -SIZE, SIZE, -SIZE,
      -SIZE, SIZE, -SIZE,
      -SIZE, SIZE, SIZE,
      -SIZE, -SIZE, SIZE,

      SIZE, -SIZE, -SIZE,
      SIZE, -SIZE, SIZE,
      SIZE, SIZE, SIZE,
      SIZE, SIZE, SIZE,
      SIZE, SIZE, -SIZE,
      SIZE, -SIZE, -SIZE,

      -SIZE, -SIZE, SIZE,
      -SIZE, SIZE, SIZE,
      SIZE, SIZE, SIZE,
      SIZE, SIZE, SIZE,
      SIZE, -SIZE, SIZE,
      -SIZE, -SIZE, SIZE,

      -SIZE, SIZE, -SIZE,
      SIZE, SIZE, -SIZE,
      SIZE, SIZE, SIZE,
      SIZE, SIZE, SIZE,
      -SIZE, SIZE, SIZE,
      -SIZE, SIZE, -SIZE,

      -SIZE, -SIZE, -SIZE,
      -SIZE, -SIZE, SIZE,
      SIZE, -SIZE, -SIZE,
      SIZE, -SIZE, -SIZE,
      -SIZE, -SIZE, SIZE,
      SIZE, -SIZE, SIZE,
    ]
    # TEXTURE_FILES = ["right", "left", "top", "bottom", "back", "front"]
    @shader : Prism::SkyboxShader
    @cube : Prism::Model

    def initialize(@shader : Prism::SkyboxShader)
      @cube = Prism::Model.load_3f(VERTICES)
    end

    def render(entities : Array(Crash::Entity))
      # TODO: display a warning or something if more than one skybox is given
      if entities.size > 0
        skybox = entities[0].get(Skybox).as(Skybox)
        # TODO: rebuild the cube if the size changes
        @shader.cube_map = skybox.texture
        # draw cube
        @cube.bind
        offset = Pointer(Void).new(0)
        LibGL.draw_arrays(LibGL::TRIANGLES, 0, @cube.vertex_count)
        @cube.unbind
      end
    end
  end
end
