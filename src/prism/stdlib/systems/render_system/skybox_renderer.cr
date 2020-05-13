module Prism::Systems
  class SkyboxRenderer
    @shader : Prism::SkyboxShader
    @cube : Prism::Model
    @size : Float32 = 500

    def initialize(@shader : Prism::SkyboxShader)
      @cube = build_cube(@size)
    end

    private def build_cube(size : Float32)
      Prism::Model.load_3f([
        -size, size, -size,
        -size, -size, -size,
        size, -size, -size,
        size, -size, -size,
        size, size, -size,
        -size, size, -size,

        -size, -size, size,
        -size, -size, -size,
        -size, size, -size,
        -size, size, -size,
        -size, size, size,
        -size, -size, size,

        size, -size, -size,
        size, -size, size,
        size, size, size,
        size, size, size,
        size, size, -size,
        size, -size, -size,

        -size, -size, size,
        -size, size, size,
        size, size, size,
        size, size, size,
        size, -size, size,
        -size, -size, size,

        -size, size, -size,
        size, size, -size,
        size, size, size,
        size, size, size,
        -size, size, size,
        -size, size, -size,

        -size, -size, -size,
        -size, -size, size,
        size, -size, -size,
        size, -size, -size,
        -size, -size, size,
        size, -size, size,
      ] of Float32)
    end

    def render(entities : Array(Crash::Entity))
      # TODO: display a warning or something if more than one skybox is given
      if entities.size > 0
        skybox = entities[0].get(Skybox).as(Skybox)
        if skybox.size != @size
          # rebuild the cube when the size changes
          @size = skybox.size
          @cube = build_cube(@size)
        end
        @shader.cube_map = skybox.texture
        @cube.bind
        offset = Pointer(Void).new(0)
        LibGL.draw_arrays(LibGL::TRIANGLES, 0, @cube.vertex_count)
        @cube.unbind
      end
    end
  end
end
