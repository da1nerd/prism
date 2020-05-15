require "./spec_helper.cr"

describe Prism::Skybox::Time do
    it "scales start of day time" do
        day_length = 60f64
        noon = Prism::Skybox::Time.new
        noon.scale(day_length).should eq(0)
    end

    it "scales just after start of day time" do
        day_length = 60f64
        noon = Prism::Skybox::Time.new(second: 1)
        noon.scale(day_length).should be_close(0, 0.001)
    end

    it "scales noon time" do
        day_length = 60f64
        noon = Prism::Skybox::Time.new(hour: 12)
        noon.scale(day_length).should eq(30)
    end

    it "scales midnight time" do
        day_length = 60f64
        noon = Prism::Skybox::Time.new(hour: 24)
        noon.scale(day_length).should eq(0)
    end

    it "scales just before midnight time" do
        day_length = 60f64
        noon = Prism::Skybox::Time.new(hour: 23, minute: 59, second: 59)
        noon.scale(day_length).should be_close(60, 0.001)
    end


    it "scales overflow day time" do
        day_length = 60f64
        noon = Prism::Skybox::Time.new(hour: 26)
        noon.scale(day_length).should eq(5)
    end
end