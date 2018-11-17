require "../src/prism"

include Prism

class MonsterLook < GameComponent
    @rendering_engine : RenderingEngineProtocol?

    def update(delta : Float32)
        if rendering_engine = @rendering_engine
            camera_pos = rendering_engine.main_camera.transform.get_transformed_pos
            camera_pos.y = 0f32

            # new_rot = self.transform.get_look_at_direction(camera_pos, Vector3f.new(0,1,0))
            # self.transform.rot = self.transform.rot.nlerp(new_rot, delta.to_f64 * 2.0f64, true)
            

            self.transform.look_at(camera_pos, Vector3f.new(0,1,0))
        end
    end

    def render(shader : Shader, rendering_engine : RenderingEngineProtocol)
        @rendering_engine = rendering_engine
    end
end
