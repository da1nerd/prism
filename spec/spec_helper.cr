require "spec"
require "../src/prism"
require "render_loop"
require "baked_file_system"

def expect_vectors_match(got : Prism::Maths::Vector2f, expected : Prism::Maths::Vector2f)
  got.x.should eq(expected.x)
  got.y.should eq(expected.y)
end

module UniformTest
  include Prism

  @[Shader::Serializable::Options(name: "Parent")]
  class Parent
    include Shader::Serializable

    @[Shader::Field(name: "name")]
    @name : Int32 = 1

    @[Shader::Field(name: "val")]
    @val : Int32 = 5
  end

  @[Shader::Serializable::Options(name: "Person")]
  class Child < Parent
    include Shader::Serializable

    @[Shader::Field(name: "age")]
    @age : Int32 = 25

    @[Shader::Field(name: "att")]
    @att : Attribute = Attribute.new
  end

  @[Shader::Serializable::Options(name: "Attribute")]
  class Attribute
    include Shader::Serializable

    @[Shader::Field(name: "color")]
    @c : Int32 = 12

    @[Shader::Field]
    @height : Int32 = 72

    @[Shader::Field(name: "method_test")]
    def test : Float32
      6.2f32
    end
  end
end

# Embeds the default shaders at compile time.
class DemoStorage
  extend BakedFileSystem

  bake_folder "./storage"
end
