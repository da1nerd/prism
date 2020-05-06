module Prism::Systems
  # TODO: move this into stdlib
  class GUIRenderer
    @shader = Prism::GUIShader.new
    @quad : Prism::Model

    def initialize
      @quad = Prism::Model.load([-1, 1, -1, -1, 1, 1, 1, -1] of Float32)
    end

    def create_transformation_matrix(translation : Vector2f, scale : Vector2f)
      translate_matrix = Matrix4f.new.init_translation(translation.x, translation.y, 0)
      scale_matrix = Matrix4f.new.init_scale(scale.x, scale.y, 1)
      return translate_matrix * scale_matrix
    end

    def render(entities : Array(Crash::Entity))

      LibGL.front_face(LibGL::CCW)
      LibGL.enable(LibGL::BLEND)
      LibGL.blend_func(LibGL::SRC_ALPHA, LibGL::ONE_MINUS_SRC_ALPHA)
      LibGL.disable(LibGL::DEPTH_TEST)
      @shader.start
      @quad.bind
      entities.each do |entity|
        gui = entity.get(GUITexture).as(GUITexture)
        @shader.gui_texture = gui.texture
        @shader.transformation_matrix = create_transformation_matrix(gui.position, gui.scale)
        LibGL.draw_arrays(LibGL::TRIANGLE_STRIP, 0, @quad.vertex_count)
      end
      LibGL.enable(LibGL::DEPTH_TEST)
      LibGL.disable(LibGL::BLEND)
      @quad.unbind
      @shader.stop
      LibGL.front_face(LibGL::CW)
    end
  end
end
