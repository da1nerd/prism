require "./shader"
require "./resource_loader"
require "./material"
require "./render_util"
require "./vector3f"
require "./directional_light"
require "./base_light"

module Prism

  class PhongShader < Shader

    @@ambient_light : Vector3f = Vector3f.new(1, 1, 1)
    @@directional_light : DirectionalLight = DirectionalLight.new(BaseLight.new(Vector3f.new(1,1,1), 0), Vector3f.new(0,0,0))

    def initialize
      super

      add_vertex_shader(ResourceLoader.load_shader("phongVertex.vert"))
      add_fragment_shader(ResourceLoader.load_shader("phongFragment.frag"))
      compile

      add_uniform("transform")
      add_uniform("transformProjected");
      add_uniform("baseColor")
      add_uniform("ambientLight")

      add_uniform("directionalLight.base.color")
      add_uniform("directionalLight.base.intensity")
      add_uniform("directionalLight.base.direction")
    end


    def update_uniforms(world_matrix : Matrix4f, projected_matrix : Matrix4f, material : Material)
      if material.texture
        material.texture.bind
      else
        RenderUtil.unbind_textures
      end

      set_uniform("transformProjected", projected_matrix)
      set_uniform("transform", world_matrix)
      set_uniform("baseColor", material.color)
      set_uniform("ambientLight", @@ambient_light)
      set_uniform("directionalLight", @@directional_light)
    end

    # Sets the global ambient light
    def self.ambient_light=(@@ambient_light : Vector3f)
    end

    # Returns the global ambient light
    def self.ambient_light
      @@ambient_light
    end

    # Sets the global directional light
    def self.directional_light=(@@directional_light : DirectionalLight)
    end

    # Returns the global directional light
    def self.directional_light
      @@directional_light
    end

    def set_uniform( name : String, base_light : BaseLight)
      set_uniform(name + ".color", base_light.color)
      set_uniform(name + ".intensity", base_light.intensity)
    end

    # Sets an integer uniform variable value
    def set_uniform( name : String, directional_light : DirectionalLight)
      set_uniform(name + ".base", directional_light.base)
      set_uniform(name + ".direction", directional_light.direction)
    end

  end
end
