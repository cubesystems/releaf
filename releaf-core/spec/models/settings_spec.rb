require "rails_helper"

describe Releaf::Settings do
  let(:values){ [{key: "a", default: "x"}, {key: "b", default: "y"}] }

  describe "#to_text" do
    it "returns var value" do
      subject.var = "x"
      expect(subject.to_text).to eq("x")
    end
  end

  describe ".registered_keys" do
    it "returns all keys from `Releaf::Settings.registry` hash" do
      described_class.registry = {}
      described_class.registry["a"] = 1
      described_class.registry["b"] = 1
      described_class.registry["c"] = 1
      expect(described_class.registered_keys.count).to eq(3)
      expect(described_class.registered_keys).to include("a", "b", "c")
    end
  end

  describe ".register" do
    before do
      described_class.destroy_all
    end

    it "iterates through given array and assign item default value to default settings by overwriting existing values" do
      described_class.defaults.delete("a")
      described_class.defaults["b"] = "z"
      expect{ described_class.register(values) }.to change{ [described_class.defaults["a"], described_class.defaults["b"]] }
        .from([nil, "z"]).to(["x", "y"])
    end

    it "iterates through given array and assign items to registry by overwriting existing values" do
      described_class.registry.delete("a")
      described_class.registry["b"] = "xx"
      expect{ described_class.register(values) }.to change{ [described_class.registry["a"], described_class.registry["b"]] }
        .from([nil, "xx"]).to(values)
    end

    it "iterates through given array and store default value to db if key does not exists in db" do
      described_class.register(key: "a", default: "z")

      expect{ described_class.register(values) }.to change{ described_class.count  }.by(1)
      expect(described_class.where(var: "a").first.value).to eq("z")
      expect(described_class.where(var: "b").first.value).to eq("y")
    end

    context "when database table does not exists" do
      it "does not store default values to db" do
        allow(described_class).to receive(:table_exists?).and_return(false)
        expect{ described_class.register(values) }.to_not change{ described_class.count  }
      end
    end
  end
end
