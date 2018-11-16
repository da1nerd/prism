require "../src/prism"

include Prism

class MonsterLook < GameComponent
    @rendering_engine : RenderingEngineProtocol?

    def update(delta : Float32)
        if rendering_engine = @rendering_engine
            camera_pos = rendering_engine.main_camera.transform.get_transformed_pos
            camera_pos.y = 0f32
            self.transform.look_at(camera_pos, Vector3f.new(0,1,0))
        end
    end

    def render(shader : Shader, rendering_engine : RenderingEngineProtocol)
        @rendering_engine = rendering_engine
    end
end
