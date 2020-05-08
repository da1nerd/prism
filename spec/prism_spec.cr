require "./spec_helper"

module Prism
  describe Prism::Shader do
    it "loads a shader program with from compiled storage" do
      program = Prism::Shader::Loader.read_shader_file "a.txt" do |path|
        DemoStorage.get(path).gets_to_end
      end
      program.should eq("line a.1\nline b.1\nline a.2\n")
    end

    it "loads a shader program with from a file" do
      program = Prism::Shader::Loader.read_shader_file "a.txt" do |path|
        File.read(File.join(__DIR__, "storage", path))
      end
      program.should eq("line a.1\nline b.1\nline a.2\n")
    end

    it "serializes an object with sub types" do
      child = UniformTest::Child.new
      child.to_uniform.should eq({
        "Person.name"            => 1,
        "Person.val"             => 5,
        "Person.age"             => 25,
        "Person.att.method_test" => 6.2f32,
        "Person.att.color"       => 12,
        "Person.att.height"      => 72,
      })
    end

    it "serializes an object" do
      att = UniformTest::Attribute.new
      att.to_uniform.should eq({
        "Attribute.method_test" => 6.2f32,
        "Attribute.color"       => 12,
        "Attribute.height"      => 72,
      })
    end
  end

  describe Prism::TextureAtlas do
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

    describe "#get_coords" do
      it "calculates the coords for index 0" do
        atlas = Prism::TextureAtlas.new(4)
        coords = atlas.get_coords(0)
        coords[:bottom_left].to_s.should eq(Prism::Maths::Vector2f.new(0.0, 0.25).to_s)
        coords[:bottom_right].to_s.should eq(Prism::Maths::Vector2f.new(0.25, 0.25).to_s)
        coords[:top_right].to_s.should eq(Prism::Maths::Vector2f.new(0.25, 0.0).to_s)
        coords[:top_left].to_s.should eq(Prism::Maths::Vector2f.new(0.0, 0.0).to_s)
      end

      it "calculates the coords for index 9" do
        atlas = Prism::TextureAtlas.new(4)
        coords = atlas.get_coords(9)
        coords[:bottom_left].to_s.should eq(Prism::Maths::Vector2f.new(0.25, 0.75).to_s)
        coords[:bottom_right].to_s.should eq(Prism::Maths::Vector2f.new(0.5, 0.75).to_s)
        coords[:top_right].to_s.should eq(Prism::Maths::Vector2f.new(0.5, 0.5).to_s)
        coords[:top_left].to_s.should eq(Prism::Maths::Vector2f.new(0.25, 0.5).to_s)
      end

      it "calculates the coords for a 1x1 atlas" do
        atlas = Prism::TextureAtlas.new(1)
        coords = atlas.get_coords(0)
        coords[:bottom_left].to_s.should eq(Prism::Maths::Vector2f.new(0.0, 1.0).to_s)
        coords[:bottom_right].to_s.should eq(Prism::Maths::Vector2f.new(1.0, 1.0).to_s)
        coords[:top_right].to_s.should eq(Prism::Maths::Vector2f.new(1.0, 0.0).to_s)
        coords[:top_left].to_s.should eq(Prism::Maths::Vector2f.new(0.0, 0.0).to_s)
      end

      it "retrieves the coords for a 1x1 atlas using an out of bounds index" do
        atlas = Prism::TextureAtlas.new(1)
        coords = atlas.get_coords(2)
        coords[:bottom_left].to_s.should eq(Prism::Maths::Vector2f.new(0.0, 1.0).to_s)
        coords[:bottom_right].to_s.should eq(Prism::Maths::Vector2f.new(1.0, 1.0).to_s)
        coords[:top_right].to_s.should eq(Prism::Maths::Vector2f.new(1.0, 0.0).to_s)
        coords[:top_left].to_s.should eq(Prism::Maths::Vector2f.new(0.0, 0.0).to_s)
      end
    end
  end
end
