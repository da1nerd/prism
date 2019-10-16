require "../../src/prism/**"
require "lib_gl"

class ModelPreview < Prism::Game
    def init
        # LibGL.polygon_mode(LibGL::FRONT_AND_BACK, LibGL::LINE)
        
        main_light = Prism::GameObject.new().add_component(Prism::DirectionalLight.new(Prism::Vector3f.new(1,1,1), 0.9))
        main_light.transform.rot = Prism::Quaternion.new(Prism::Vector3f.new(1f32, 0f32, 0f32), Prism.to_rad(-45f32))
        add_object(main_light)

        plain = Prism::ShapeFactory.plain(5, 10)
        add_object(plain)

        add_object(Prism::GhostCamera.new)

        material = Prism::Material.new()
        material.add_texture("diffuse", Prism::Texture.new("defaultTexture.png"))
        material.add_float("specularIntensity", 1)
        material.add_float("specularPower", 8)
        add_object(Prism::GameObject.new().add_component(Prism::MeshRenderer.new(Prism::Mesh.new("monkey3.obj"), material)))
    end

end

# Start the engine
engine = Prism::CoreEngine.new(800, 600, 60.0, "Model Preview", ModelPreview.new())
engine.start
