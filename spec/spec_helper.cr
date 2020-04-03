require "spec"
require "../src/prism"
require "prism-core"

def expect_vectors_match(got : Prism::Vector2f, expected : Prism::Vector2f)
  got.x.should eq(expected.x)
  got.y.should eq(expected.y)
end

class TestGame < Prism::Game
  def init
  end
end

module UniformTest
  include Prism::Uniform

  class Parent
    include Serializable

    @[Field(struct: "Person", key: "name")]
    @name : Int32 = 1

    @[Field(key: "val")]
    @val : Int32 = 5
  end

  class Child < Parent
    include Serializable

    @[Field(struct: "Person", key: "age")]
    @age : Int32 = 25

    @[Field(struct: "Person", key: "att")]
    @att : Attribute = Attribute.new
  end

  class Attribute
    include Serializable

    @[Field(key: "color")]
    @c : Int32 = 12

    @[Field]
    @height : Int32 = 72

    @[Field(key: "method_test")]
    def test : Float32
      6.2f32
    end
  end
end
