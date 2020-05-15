require "annotation"

module Prism::Systems
  class SkyboxRenderer
    @shader : Prism::SkyboxShader
    @cube : Prism::Model
    @size : Float32 = 500

    def initialize(@shader : Prism::SkyboxShader, @fog_color : Vector3f)
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

        values = skybox.get_values

        @shader.fog_color = @fog_color
        @shader.cube_map = values[:current_texture]
        @shader.cube_map2 = values[:next_texture]
        @shader.blend_factor = values[:blend_factor]
        @cube.bind
        offset = Pointer(Void).new(0)
        LibGL.draw_arrays(LibGL::TRIANGLES, 0, @cube.vertex_count)
        @cube.unbind
      end
    end
  end
end
