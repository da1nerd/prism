require "./spec_helper"
include Prism

class MyType
  ReferencePool.create_persistent_pool(String) { }
end

class MyChildType < MyType
end

class MyOtherType
  ReferencePool.create_persistent_pool(String) { }
end

describe MyType do
  it "maintains the pool across inheritance" do
    MyType.pool.size.should eq(0)
    MyChildType.pool.size.should eq(0)
    MyOtherType.pool.size.should eq(0)

    MyType.pool.add("key", "value")

    MyType.pool.size.should eq(1)
    MyChildType.pool.size.should eq(1)
    MyOtherType.pool.size.should eq(0)

    MyChildType.pool.add("key2", "value")

    MyType.pool.size.should eq(2)
    MyChildType.pool.size.should eq(2)
    MyOtherType.pool.size.should eq(0)

    MyOtherType.pool.add("key", "value")

    MyType.pool.size.should eq(2)
    MyChildType.pool.size.should eq(2)
    MyOtherType.pool.size.should eq(1)
  end
end

describe Prism::ReferencePool(String) do
  it "adds a resource to the pool" do
    pool = Prism::ReferencePool(String).new { }
    pool.has_key?("key").should eq(false)
    pool.add("key", "value")
    pool.has_key?("key").should eq(true)
    pool.reference_count("key").should eq(0)
  end

  it "uses a pooled reference" do
    value = "value"
    pool = Prism::ReferencePool(String).new { }
    pool.add("key", value)
    pool.reference_count("key").should eq(0)
    used_value = pool.use("key")
    used_value.should be(value)
    pool.reference_count("key").should eq(1)
  end

  it "trashes a reference" do
    pool = Prism::ReferencePool(String).new { }
    pool.add("key", "value")
    pool.use("key")
    pool.use("key")
    pool.reference_count("key").should eq(2)
    pool.trash("key")
    pool.reference_count("key").should eq(1)
  end

  it "deletes an orphaned resource" do
    pool = Prism::ReferencePool(String).new { }
    pool.add("key", "value")
    pool.use("key")
    pool.reference_count("key").should eq(1)
    pool.trash("key")
    pool.has_key?("key").should eq(false)
  end
end
