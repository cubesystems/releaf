require "rails_helper"

describe Releaf::Settings do

  describe ":registered scope" do
    it "returns only registed settings ordered by `var`" do
      registered = described_class.where(var: "x")
      allow(described_class).to receive(:registered_keys).and_return([:a, :b])
      allow(described_class).to receive(:where).with(var: [:a, :b]).and_return(registered)
      allow(registered).to receive(:order).with(:var).and_return(:c)
      expect(described_class.registered).to eq(:c)
    end

    it "returns valid query" do
      expect(described_class.registered.count).to be_instance_of(Fixnum)
    end

    it "returns instance of `Releaf::Settings::ActiveRecord_Relation`" do
      expect(described_class.registered).to be_instance_of(Releaf::Settings::ActiveRecord_Relation)
    end
  end

  describe "#releaf_title" do
    it "returns var value" do
      subject.var = "x"
      expect(subject.releaf_title).to eq("x")
    end
  end

  describe "#input_type" do
    it "returns type from metadata" do
      allow(subject).to receive(:metadata).and_return(type: "xx")
      expect(subject.input_type).to eq("xx")
    end

    context "when type not defined in meta data" do
      it "returns `:text` as default value" do
        allow(subject).to receive(:metadata).and_return(type: nil)
        expect(subject.input_type).to eq(:text)

        allow(subject).to receive(:metadata).and_return(asdasd: "xx")
        expect(subject.input_type).to eq(:text)
      end
    end
  end

  describe "#description" do
    it "returns type from metadata" do
      allow(subject).to receive(:metadata).and_return(description: "xxasd")
      expect(subject.description).to eq("xxasd")
    end
  end

  describe "#metadata" do
    before do
      subject.var = "xxx"
    end

    it "returns metadata values from settings registry fetched by object `var` value" do
      allow(described_class).to receive(:registry).and_return("xxx" => {a: "b"})
      expect(subject.metadata).to eq(a: "b")
    end

    context "when metadata does not exist" do
      it "returns empty hash" do
        allow(described_class).to receive(:registry).and_return("lasdh" => {a: "b"})
        expect(subject.metadata).to eq({})
      end
    end
  end

  describe ".register_scoped" do
    it "returns only register scoped settings" do
      allow(described_class).to receive(:where).with(var: ["a", "b"]).and_return("x")
      allow(described_class).to receive(:registered_keys).and_return(["a", "b"])

      expect(described_class.register_scoped).to eq("x")
    end

    it "returns instance of `Releaf::Settings::ActiveRecord_Relation`" do
      expect(described_class.register_scoped).to be_instance_of(Releaf::Settings::ActiveRecord_Relation)
    end
  end

  describe ".register" do
    it "calls `Releaf::Settings::Register` service with given arguments as array" do
      expect(Releaf::Settings::Register).to receive(:call)
        .with(settings: [{key: "a", type: "b"}, {key: "c", type: "d"}])
      described_class.register({key: "a", type: "b"}, {key: "c", type: "d"})
    end
  end

  describe ".supported_types" do
    it "returns list of supported types as array with symbols" do
      described_class.supported_types.each do|type|
        expect(type).to be_instance_of Symbol
      end
    end
  end
end
