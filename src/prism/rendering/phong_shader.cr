require "./shader"
require "./material"
require "../core/vector3f"
require "./directional_light"
require "./base_light"
require "./point_light"
require "./spot_light"

module Prism

  class PhongShader < Shader

    MAX_POINT_LIGHTS = 4;
    MAX_SPOT_LIGHTS = 4;

    @@ambient_light : Vector3f = Vector3f.new(1, 1, 1)
    @@directional_light : DirectionalLight = DirectionalLight.new(BaseLight.new(Vector3f.new(1,1,1), 0), Vector3f.new(0,0,0))
    @@point_lights = [] of PointLight
    @@spot_lights = [] of SpotLight

    def initialize
      super

      add_vertex_shader_from_file("phongVertex.vert")
      add_fragment_shader_from_file("phongFragment.frag")
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
        add_uniform("pointLights[#{i}].range")
      end

      0.upto(MAX_SPOT_LIGHTS - 1) do |i|
        add_uniform("spotLights[#{i}].pointLight.base.color")
        add_uniform("spotLights[#{i}].pointLight.base.intensity")
        add_uniform("spotLights[#{i}].pointLight.atten.constant")
        add_uniform("spotLights[#{i}].pointLight.atten.linear")
        add_uniform("spotLights[#{i}].pointLight.atten.exponent")
        add_uniform("spotLights[#{i}].pointLight.position")
        add_uniform("spotLights[#{i}].pointLight.range")

        add_uniform("spotLights[#{i}].direction")
        add_uniform("spotLights[#{i}].cutoff")
      end
    end


    def update_uniforms(transform : Transform, material : Material)

      world_matrix = transform.get_transformation
      projected_matrix = rendering_engine.main_camera.get_view_projection * world_matrix
      material.texture.bind

      set_uniform("transformProjected", projected_matrix)
      set_uniform("transform", world_matrix)
      set_uniform("baseColor", material.color)

      set_uniform("ambientLight", @@ambient_light)
      set_uniform("directionalLight", @@directional_light)

      0.upto(@@point_lights.size - 1) do |i|
        set_uniform("pointLights[#{i}]", @@point_lights[i])
      end

      0.upto(@@spot_lights.size - 1) do |i|
        set_uniform("spotLights[#{i}]", @@spot_lights[i])
      end

      set_uniform("specularIntensity", material.specular_intensity)
      set_uniform("specularExponent", material.specular_exponent)

      set_uniform("eyePos", rendering_engine.main_camera.pos)
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

    # Sets the global spot lights
    def self.spot_lights=(spot_lights : Array(SpotLight))
      if spot_lights.size > MAX_SPOT_LIGHTS
        puts "Error: You passed in too many spot lights. Max allowed is #{MAX_SPOT_LIGHTS}, you passed in #{spot_lights.size}"
        exit 1
      end

      @@spot_lights = spot_lights
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
      set_uniform(name + ".range", point_light.range)
    end

    def set_uniform( name : String, spot_light : SpotLight)
      set_uniform(name + ".pointLight", spot_light.point_light)
      set_uniform(name + ".direction", spot_light.direction)
      set_uniform(name + ".cutoff", spot_light.cutoff)
    end

  end
end
