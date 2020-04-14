require "lib_gl"

module Prism::Core::Render
  # Handles the rendering.
  class Renderer
    def prepare
      LibGL.clear_color(1, 0, 0, 1)
    end

    # Draws a `RawModel`
    def render(model : RawModel)
      LibGL.bind_vertex_array(model.vao_id)
      LibGL.enable_vertex_attrib_array(0)
      LibGL.draw_arrays(LibGL::TRIANGLES, 0, model.vertex_count)
      LibGL.disable_vertex_attib_array(0)
      LibGL.bind_vertex_array(0)
    end
  end
end
