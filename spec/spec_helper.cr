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

  @[Shader::UniformStruct::Options(name: "Parent")]
  class Parent
    include Shader::UniformStruct

    @[Field(name: "name")]
    @name : Int32 = 1

    @[Field(name: "val")]
    @val : Int32 = 5
  end

  @[Shader::UniformStruct::Options(name: "Person")]
  class Child < Parent
    include Shader::UniformStruct

    @[Field(name: "age")]
    @age : Int32 = 25

    @[Field(name: "att")]
    @att : Attribute = Attribute.new
  end

  @[Shader::UniformStruct::Options(name: "Attribute")]
  class Attribute
    include Shader::UniformStruct

    @[Field(name: "color")]
    @c : Int32 = 12

    @[Field]
    @height : Int32 = 72

    @[Field(name: "method_test")]
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
