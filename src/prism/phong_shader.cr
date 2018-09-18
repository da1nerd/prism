require "./shader"
require "./resource_loader"
require "./material"
require "./render_util"
require "./vector3f"

module Prism

  class PhongShader < Shader

    @@ambient_light : Vector3f = Vector3f.new(1, 1, 1)

    def initialize
      super

      add_vertex_shader(ResourceLoader.load_shader("phongVertex.vs"))
      add_fragment_shader(ResourceLoader.load_shader("phongFragment.fs"))
      compile

      add_uniform("transform")
      add_uniform("baseColor")
      add_uniform("ambientLight")
    end


    def update_uniforms(world_matrix : Matrix4f, projected_matrix : Matrix4f, material : Material)
      if material.texture
        material.texture.bind
      else
        RenderUtil.unbind_textures
      end

      set_uniform("transform", projected_matrix)
      set_uniform("baseColor", material.color)
      set_uniform("ambientLight", @@ambient_light)
    end

    # Sets the global ambient light
    def self.ambient_light=(@@ambient_light : Vector3f)
    end

    # Returns the global ambient light
    def self.ambient_light
      @@ambient_light
    end

  end
end
