require "../src/prism"

include Prism

class LookAtComponent < GameComponent
    @rendering_engine : RenderingEngineProtocol?

    def update(delta : Float32)
        if rendering_engine = @rendering_engine
            new_rot = self.transform.get_look_at_direction(rendering_engine.main_camera.transform.get_transformed_pos, Vector3f.new(0,1,0))
            self.transform.rot = self.transform.rot.nlerp(new_rot, delta.to_f64 * 5.0f64, true)
            # self.transform.rot = self.transform.rot.slerp(new_rot, delta.to_f64 * 5.0f64, true)

        end
    end

    def render(shader : Shader, rendering_engine : RenderingEngineProtocol)
        @rendering_engine = rendering_engine
    end
end
