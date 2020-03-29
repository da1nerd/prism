require "spec"
require "../src/prism"
require "prism-core"

def expect_vectors_match(got : Prism::Vector2f, expected : Prism::Vector2f)
  got.x.should eq(expected.x)
  got.y.should eq(expected.y)
end
