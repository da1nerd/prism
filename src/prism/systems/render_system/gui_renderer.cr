module Prism::Systems
  # TODO: move this into stdlib
  class GUIRenderer
    QUAD = Prism::Model.load([-1, 1, -1, -1, 1, 1, 1, -1] of Float32)

    @shader = Prism::GUIShader.new

    def create_transformation_matrix(translation : Vector2f, scale : Vector2f)
      translate_matrix = Matrix4f.new.init_translation(translation.x, translation.y, 0)
      scale_matrix = Matrix4f.new.init_scale(scale.x, scale.y, 1)
      return scale_matrix * translate_matrix
    end

    def render(entities : Array(Crash::Entity))
      @shader.start
      QUAD.bind
      entities.each do |entity|
        gui = entity.get(GUITexture).as(GUITexture)
        @shader.gui_texture = gui.texture
        @shader.transformation_matrix = create_transformation_matrix(gui.position, gui.scale)
        LibGL.draw_arrays(LibGL::TRIANGLE_STRIP, 0, QUAD.vertex_count)
      end
      QUAD.unbind
      @shader.stop
    end
  end
end
