require "./spec_helper"

describe Prism::Core::Clock do
  it "increments the time" do
    Prism::Core::Clock.reset
    Prism::Core::Clock.tick(1)
    Prism::Core::Clock.seconds.should eq(1)
    Prism::Core::Clock.tick(0.1)
    Prism::Core::Clock.seconds.should eq(1.1)
  end
end

describe Prism::Clock do
  it "creates a new unscaled instance" do
    clock = Prism::Clock.new(hour: 1, minute: 1, second: 1)
    clock.real_seconds.should eq(3661)
  end

  it "creates a new instance scaled to 12 hours" do
    clock = Prism::Clock.new(hour: 1, minute: 1, second: 1, day_length: 12*60*60f64)
    clock.real_seconds.should eq(1830.5)
  end

  it "creates a new instance scaled to 1 minute" do
    clock = Prism::Clock.new(hour: 12, day_length: 60.0)
    clock.real_seconds.should eq(30.0)
  end

  it "gets the current unscaled instance" do
    Prism::Core::Clock.reset
    clock = Prism::Clock.now
    clock.real_seconds.should eq(0)
  end

  it "gets the current unscaled instance after time has passed" do
    Prism::Core::Clock.reset(12)
    clock = Prism::Clock.now
    clock.real_seconds.should eq(12)
  end

  it "scales start of day time" do
    clock = Prism::Clock.new(day_length: 60)
    clock.real_seconds.should eq(0)
  end

  it "scales just after start of day time" do
    clock = Prism::Clock.new(second: 1, day_length: 60)
    clock.real_seconds.should be_close(0, 0.001)
  end

  it "scales noon time" do
    clock = Prism::Clock.new(hour: 12, day_length: 60)
    clock.real_seconds.should eq(30)
  end

  it "scales midnight time" do
    clock = Prism::Clock.new(hour: 24, day_length: 60)
    clock.real_seconds.should eq(0)
  end

  it "scales just before midnight time" do
    clock = Prism::Clock.new(hour: 23, minute: 59, second: 59, day_length: 60)
    clock.real_seconds.should be_close(60, 0.001)
  end

  it "scales overflow day time" do
    clock = Prism::Clock.new(hour: 26, day_length: 60)
    clock.real_seconds.should eq(5)
  end

  it "changes the time" do
    Prism::Core::Clock.reset
    Prism::Clock.now.real_seconds.should eq(0)

    Prism::Clock.set_time Prism::Clock.new(hour: 12, day_length: 60)
    Prism::Clock.now.real_seconds.should eq(30)
  end
end
