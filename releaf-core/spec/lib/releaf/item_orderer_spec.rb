require "rails_helper"

describe Releaf::ItemOrderer do
  let(:list){ ["a", "b", "c", "d", {items: "xx"}, "e", "f", "g"] }
  subject{ described_class.new(*list) }

  describe "#initialize" do
    it "assigns given arguments to list accessor" do
      subject = described_class.new(:a, :b, :c)
      expect(subject.list).to eq([:a, :b, :c])
    end
  end

  describe "#result" do
    it "returns list" do
      expect(subject.result).to eq(list)
      subject.reorder(:a, :last)
      expect(subject.result).to eq(["b", "c", "d", {items: "xx"}, "e", "f", "g", "a"])
    end
  end

  describe "#to_a" do
    it "returns result" do
      allow(subject).to receive(:result).and_return(:x)
      expect(subject.to_a).to eq(:x)
    end
  end

  describe "#reorder" do
    it "returns instance of itself" do
      expect(subject.reorder(:a, :last)).to eq(subject)
    end

    it "deletes given values and insert deleted values in reversed order at reorder index" do
      deleted_values = {a: "x", b: "y"}

      expect(subject).to receive(:delete).with([:a, :b]).ordered.and_return(deleted_values)
      expect(subject).to receive(:reorder_index).with(:last).ordered.and_return(1)

      expect{ subject.reorder([:a, :b], :last) }.to change{ subject.list }
        .to(["a", "x", "y", "b", "c", "d", {items: "xx"}, "e", "f", "g"])
    end

    context "when given value is array" do
      it "process unmodified given value" do
        expect(subject).to receive(:delete).with([:a]).and_call_original
        subject.reorder([:a], :last)
      end
    end

    context "when given value is not array" do
      it "puts value within array" do
        expect(subject).to receive(:delete).with([:a]).and_call_original
        subject.reorder(:a, :last)
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
      it "returns size of current list array" do
        expect(subject.reorder_index(:last)).to eq(8)
        subject.list = [:a, :b]
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
    it "returns value index by comparing list and given values casted to strings" do
      expect(subject.index(:c)).to eq(2)
      expect(subject.index("c")).to eq(2)
      subject.list = ["a", :b, :c]
      expect(subject.index("c")).to eq(2)
    end

    context "when list value is Hash" do
      it "compares by hash first key casted to string" do
        expect(subject.index(:items)).to eq(4)
        expect(subject.index("items")).to eq(4)

        subject.list = ["a", {"items" => "x"}]
        expect(subject.index(:items)).to eq(1)
        expect(subject.index("items")).to eq(1)
      end
    end
  end

  describe "#delete" do
    before do
      subject.list = [:a, :b, :c, :d, {items: "x"}]
    end

    it "deletes given values from list" do
      expect{ subject.delete(["a", "b", "items"]) }.to change{ subject.list }.to([:c, :d])
    end

    it "returns hash with mapped deleted values" do
      expect(subject.delete(["a", "b", "items"])).to eq("a" => :a, "b" => :b, "items" => {items: "x"})
    end
  end

  describe ".reorder" do
    it "returns reordered array by given options" do
      result = described_class.reorder(list,
                      [:a, :b] => {after: :c},
                      d: {before: :c},
                      g: :first,
                      [:e, :f] => {before: :g},
                      c:  {after: :items},
                      items: :first
                     )
      expect(result).to eq([{:items=>"xx"}, "e", "f", "g", "d", "a", "b", "c"])
    end
  end
end
