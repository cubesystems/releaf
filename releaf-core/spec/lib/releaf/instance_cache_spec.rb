require "rails_helper"

describe Releaf::InstanceCache, type: :class do
  class InstanceCacheIncluder
    include Releaf::InstanceCache
    cache_instance_methods :some_value, :another_value
    cache_instance_method :one_more_another_value

    def calculated_value
      instance_cache(:calculated_value) do
        some_value
      end
    end

    def some_value
      1 + 2
    end

    def another_value
      "xx"
    end

    def one_more_another_value
      "yy"
    end
  end

  subject{ InstanceCacheIncluder.new }

  it "keeps previously defined `method_added` method" do
    class InstanceCacheIncluder2
      cattr_accessor :test_value

      def self.method_added(method_name)
        self.test_value = method_name if method_name == :some_value
      end
      include Releaf::InstanceCache
      cache_instance_method :some_value

      def some_value
        :xx
      end
    end

    subject = InstanceCacheIncluder2.new
    expect(InstanceCacheIncluder2.test_value).to eq(:some_value)
    allow(subject).to receive(:instance_cache_original_some_value).and_return(:yyy).once
    expect(subject.some_value).to eq(:yyy)
    subject.some_value
  end

  describe ".instance_cache_original_method_name" do
    it "returns name of uncached original method name" do
      expect(subject.class.instance_cache_original_method_name(:some_method)).to eq("instance_cache_original_some_method")
    end
  end

  describe "#instance_cache" do
    it "stores block value to instance cache store" do
      expect{ subject.calculated_value }.to change{ subject.instance_cache_store[:calculated_value] }.to(3)
    end

    it "returns returns value when caching happen" do
      expect(subject.calculated_value).to eq(3)
    end

    it "returns cached value when called second time" do
      subject.calculated_value
      expect(subject.calculated_value).to eq(3)
    end

    it "does not evaluate block twice when called second time" do
      expect(subject).to receive(:some_value).and_call_original.once
      subject.calculated_value
      subject.calculated_value
    end
  end

  describe "#reset_instance_cache" do
    it "assigns empty hash to instance hash store" do
      subject.instance_cache_store[:x] = 1
      expect{ subject.reset_instance_cache }.to change{ subject.instance_cache_store }.from(x: 1).to({})
    end
  end

  describe ".cache_instance_methods" do
    it "adds cache wrapper for all given methods" do
      expect(subject.class.cached_instance_methods).to eq([:some_value, :another_value, :one_more_another_value])

      allow(subject).to receive(:instance_cache_original_another_value).and_return("xxx").once
      expect(subject).to receive(:instance_cache) do|x, &block|
        expect(block.call).to eq("xxx")
      end.and_return("yyy")

      expect(subject.another_value).to eq("yyy")
    end
  end
end
