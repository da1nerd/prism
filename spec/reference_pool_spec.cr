require "./spec_helper"

describe Prism::ReferencePool do
  it "adds a resource to the pool" do
    pool = Prism::ReferencePool(String).new
    pool.has_key?("key").should eq(false)
    pool.add("key", "value")
    pool.has_key?("key").should eq(true)
    pool.reference_count("key").should eq(0)
  end

  it "uses a pooled reference" do
    value = "value"
    pool = Prism::ReferencePool(String).new
    pool.add("key", value)
    pool.reference_count("key").should eq(0)
    used_value = pool.use("key")
    used_value.should be(value)
    pool.reference_count("key").should eq(1)
  end

  it "trashes a reference" do
    pool = Prism::ReferencePool(String).new
    pool.add("key", "value")
    pool.use("key")
    pool.use("key")
    pool.reference_count("key").should eq(2)
    pool.trash("key")
    pool.reference_count("key").should eq(1)
  end

  it "deletes an orphaned resource" do
    pool = Prism::ReferencePool(String).new
    pool.add("key", "value")
    pool.use("key")
    pool.reference_count("key").should eq(1)
    pool.trash("key")
    pool.has_key?("key").should eq(false)
  end
end
