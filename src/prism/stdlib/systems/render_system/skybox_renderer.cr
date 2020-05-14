require "annotation"

module Prism::Systems
  class SkyboxRenderer
    @shader : Prism::SkyboxShader
    @cube : Prism::Model
    @size : Float32 = 500
    @time : Float32 = 0

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

    def tick(tick : RenderLoop::Tick)
      @time += tick.frame_time.to_f32
      @time %= 8
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

        blend_factor = 0
        texture1 : Prism::TextureCubeMap
        texture2 : Prism::TextureCubeMap

        if @time >= 0 && @time < 2
          texture1 = skybox.night_texture
          texture2 = skybox.night_texture
          blend_factor = (@time - 0)/(2 - 0)
        elsif @time >= 2 && @time < 4
          texture1 = skybox.night_texture
          texture2 = skybox.day_texture
          blend_factor = (@time - 2)/(4 - 2)
        elsif @time >= 4 && @time < 6
          texture1 = skybox.day_texture
          texture2 = skybox.day_texture
          blend_factor = (@time - 4)/(6 - 4)
        else
          texture1 = skybox.day_texture
          texture2 = skybox.night_texture
          blend_factor = (@time - 6)/(8 - 6)
        end

        @shader.fog_color = @fog_color
        @shader.cube_map = texture1
        @shader.cube_map2 = texture2
        @shader.blend_factor = blend_factor
        @cube.bind
        offset = Pointer(Void).new(0)
        LibGL.draw_arrays(LibGL::TRIANGLES, 0, @cube.vertex_count)
        @cube.unbind
      end
    end
  end
end
