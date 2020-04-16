require "lib_gl"

module Prism::Core::Render
  # Handles the rendering.
  class Renderer
    def prepare
      LibGL.clear(LibGL::COLOR_BUFFER_BIT)
      LibGL.clear_color(1, 0, 0, 1)
    end

    # Draws a `RawModel`
    def render(model : RawModel)
      prepare
      LibGL.bind_vertex_array(model.vao_id)
      LibGL.enable_vertex_attrib_array(0)
      LibGL.draw_elements(LibGL::TRIANGLES, model.vertex_count, LibGL::UNSIGNED_INT, Pointer(Void).new(0))
      LibGL.disable_vertex_attrib_array(0)
      LibGL.bind_vertex_array(0)

      # LibGL.viewport(0, 0, 800, 600)
      # LibGL.flush
    end
  end
end
