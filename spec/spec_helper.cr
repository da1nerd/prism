require "spec"
require "../src/prism"
require "render_loop"

def expect_vectors_match(got : Prism::Vector2f, expected : Prism::Vector2f)
  got.x.should eq(expected.x)
  got.y.should eq(expected.y)
end

module UniformTest
  include Prism

  class Parent
    include Shader::Serializable

    @[Shader::Field(struct: "Person", key: "name")]
    @name : Int32 = 1

    @[Shader::Field(key: "val")]
    @val : Int32 = 5
  end

  class Child < Parent
    include Shader::Serializable

    @[Shader::Field(struct: "Person", key: "age")]
    @age : Int32 = 25

    @[Shader::Field(struct: "Person", key: "att")]
    @att : Attribute = Attribute.new
  end

  class Attribute
    include Shader::Serializable

    @[Shader::Field(key: "color")]
    @c : Int32 = 12

    @[Shader::Field]
    @height : Int32 = 72

    @[Shader::Field(key: "method_test")]
    def test : Float32
      6.2f32
    end
  end
end
