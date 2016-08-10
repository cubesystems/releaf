require "rails_helper"

describe Array::Reorder do
  subject{ described_class.new(array: ["a", "b", "c", "d", {items: "xx"}, "e", "f", "g"],
                               values: "c", options: :first) }

  describe "#values=" do
    context "when `values` is not array" do
      it "wraps it within array before assigning" do
        expect{ subject.values = :a }.to change{ subject.values }.to([:a])
      end
    end

    context "when `values` is array" do
      it "does not modify it before assigning" do
        expect{ subject.values = [:a] }.to change{ subject.values }.to([:a])
      end
    end
  end

  describe "#call" do
    it "deletes given values and insert deleted values in reversed order at reorder index" do
      deleted_values = {a: "x", b: "y"}
      subject.values = [:a, :b]
      subject.options = :last

      expect(subject).to receive(:delete).with([:a, :b]).ordered.and_return(deleted_values)
      expect(subject).to receive(:reorder_index).with(:last).ordered.and_return(1)
      expect{ subject.call }.to change{ subject.array }
        .to(["a", "x", "y", "b", "c", "d", {items: "xx"}, "e", "f", "g"])
    end

    context "when given value is array" do
      it "process unmodified given value" do
        subject.values = [:a]
        subject.options = :last
        expect(subject).to receive(:delete).with([:a]).and_call_original
        subject.call
      end
    end

    context "when given value is not array" do
      it "puts value within array" do
        subject.values = [:a]
        subject.options = :last
        expect(subject).to receive(:delete).with([:a]).and_call_original
        subject.call
      end
    end
  end

  describe "#reorder_index" do
    context "when given options is :first" do
      it "returns 0" do
        expect(subject.reorder_index(:first)).to eq(0)
      end
    end

    context "when given options is :last" do
      it "returns size of array" do
        expect(subject.reorder_index(:last)).to eq(8)
        subject.array = [:a, :b]
        expect(subject.reorder_index(:last)).to eq(2)
      end
    end

    context "when given options is :before" do
      it "returns index of given `before` value" do
        allow(subject).to receive(:index).with(:items).and_return(4)
        expect(subject.reorder_index(before: :items)).to eq(4)
      end
    end

    context "when given options is :after" do
      it "returns index of given `after` value increased by 1" do
        allow(subject).to receive(:index).with(:items).and_return(4)
        expect(subject.reorder_index(after: :items)).to eq(5)
      end
    end

    context "when unknown option given" do
      it "raises ArgumentError" do
        expect{ subject.reorder_index(asdasd: :items) }.to raise_error(ArgumentError, "unknown reorder option")
      end
    end
  end

  describe "#index" do
    it "returns value index by comparing array and given values casted to strings" do
      expect(subject.index(:c)).to eq(2)
      expect(subject.index("c")).to eq(2)
      subject.array = ["a", :b, :c]
      expect(subject.index("c")).to eq(2)
    end

    context "when array value is Hash" do
      it "compares by hash first key casted to string" do
        expect(subject.index(:items)).to eq(4)
        expect(subject.index("items")).to eq(4)

        subject.array = ["a", {"items" => "x"}]
        expect(subject.index(:items)).to eq(1)
        expect(subject.index("items")).to eq(1)
      end
    end
  end

  describe "#delete" do
    before do
      subject.array = [:a, :b, :c, :d, {items: "x"}]
    end

    it "deletes given values from array" do
      expect{ subject.delete(["a", "b", "items"]) }.to change{ subject.array }.to([:c, :d])
    end

    it "returns hash with mapped deleted values" do
      expect(subject.delete(["a", "b", "items"])).to eq("a" => :a, "b" => :b, "items" => {items: "x"})
    end
  end
end
