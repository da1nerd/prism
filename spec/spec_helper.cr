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
    @name : String = "Jon"

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
    @color : String = "brown"

    @[Field(key: "height")]
    @height : Int32 = 72
  end
end
