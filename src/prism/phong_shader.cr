require "./shader"
require "./resource_loader"
require "./material"
require "./render_util"
require "./vector3f"
require "./directional_light"
require "./base_light"
require "./point_light"

module Prism

  class PhongShader < Shader

    MAX_POINT_LIGHTS = 4;

    @@ambient_light : Vector3f = Vector3f.new(1, 1, 1)
    @@directional_light : DirectionalLight = DirectionalLight.new(BaseLight.new(Vector3f.new(1,1,1), 0), Vector3f.new(0,0,0))
    @@point_lights = [] of PointLight

    def initialize
      super

      add_vertex_shader(ResourceLoader.load_shader("phongVertex.vert"))
      add_fragment_shader(ResourceLoader.load_shader("phongFragment.frag"))
      compile

      add_uniform("transform")
      add_uniform("transformProjected")
      add_uniform("baseColor")
      add_uniform("ambientLight")

      add_uniform("specularIntensity")
      add_uniform("specularExponent")
      add_uniform("eyePos")

      add_uniform("directionalLight.base.color")
      add_uniform("directionalLight.base.intensity")
      add_uniform("directionalLight.direction")

      0.upto(MAX_POINT_LIGHTS - 1) do |i|
        add_uniform("pointLights[#{i}].base.color")
        add_uniform("pointLights[#{i}].base.intensity")
        add_uniform("pointLights[#{i}].atten.constant")
        add_uniform("pointLights[#{i}].atten.linear")
        add_uniform("pointLights[#{i}].atten.exponent")
        add_uniform("pointLights[#{i}].position")
      end
    end


    def update_uniforms(world_matrix : Matrix4f, projected_matrix : Matrix4f, material : Material, camera_position : Vector3f)
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

      0.upto(@@point_lights.size - 1) do |i|
        set_uniform("pointLights[#{i}]", @@point_lights[i])
      end

      set_uniform("specularIntensity", material.specular_intensity)
      set_uniform("specularExponent", material.specular_exponent)

      set_uniform("eyePos", camera_position)
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

    # Sets the global point lights
    def self.point_lights=(point_lights : Array(PointLight))
      if point_lights.size > MAX_POINT_LIGHTS
        puts "Error: You passed in too many point lights. Max allowed is #{MAX_POINT_LIGHTS}, you passed in #{point_lights.size}"
        exit 1
      end

      @@point_lights = point_lights
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

    def set_uniform( name : String, point_light : PointLight)
      set_uniform(name + ".base", point_light.base_light)
      set_uniform(name + ".atten.constant", point_light.atten.constant)
      set_uniform(name + ".atten.linear", point_light.atten.linear)
      set_uniform(name + ".atten.exponent", point_light.atten.exponent)
      set_uniform(name + ".position", point_light.position)
    end

  end
end
