require "./spec_helper"

describe Prism do
  describe Prism::Adapter::GLFW do
    it "runs" do
      # TODO: kill after a moment
      game = TestGame.new
      # Prism::Adapter::GLFW.run("Demo", game)
    end
  end

  describe Prism::Uniform do
    it "serializes uniforms" do
      child = UniformTest::Child.new
      child.to_uniform.should eq({
        "val"                    => 5,
        "Person.name"            => "Jon",
        "Person.age"             => 25,
        "Person.att.color"       => "brown",
        "Person.att.height"      => 72,
        "Person.att.method_test" => "test",
      })
    end
  end

  describe Prism::Spritemap do
    # This is our sample test grid
    # +---------------+
    # | 0 | 1 | 2 | 3 |
    # |---|---|---|---|
    # | 4 | 5 | 6 | 7 |
    # |---|---|---|---|
    # | 8 | 9 | 10| 11|
    # |---|---|---|---|
    # | 12| 13| 14| 15|
    # +---------------+

    describe "#get_coordinates" do
      it "calculates the coords for index 0" do
        coords = Prism::Spritemap.get_coordinates(0, 4)
        coords.should eq({
          col: 0,
          row: 0,
        })
      end

      it "calculates the coords for index 9" do
        coords = Prism::Spritemap.get_coordinates(9, 4)
        coords.should eq({
          col: 1,
          row: 2,
        })
      end

      it "calculates the coords for index 12" do
        coords = Prism::Spritemap.get_coordinates(12, 4)
        coords.should eq({
          col: 0,
          row: 3,
        })
      end

      it "calculates the coords for index 15" do
        coords = Prism::Spritemap.get_coordinates(15, 4)
        coords.should eq({
          col: 3,
          row: 3,
        })
      end
    end

    describe "#get_sprite_coordinates" do
      it "returns the coords" do
        coords = Prism::Spritemap.get_sprite_coordinates(1, 1, 4, 4)
        expect_vectors_match(coords[:bottom_left], Prism::Vector2f.new(0.25, 0.5))
        expect_vectors_match(coords[:bottom_right], Prism::Vector2f.new(0.5, 0.5))
        expect_vectors_match(coords[:top_right], Prism::Vector2f.new(0.5, 0.25))
        expect_vectors_match(coords[:top_left], Prism::Vector2f.new(0.25, 0.25))
      end
    end
  end
end
