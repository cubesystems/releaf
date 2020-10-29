require "rails_helper"

describe Releaf::Settings::NormalizeValue do
  let(:subject){ described_class.new(value: "x", input_type: :date) }

  describe "#call" do
    before do
      allow(subject).to receive(:normalization_method).and_return("normalize_time")
      allow(described_class).to receive(:normalize_time).and_return("a")
    end

    context "when normalization method exists for given input type" do
      it "returns value normalize with normalization method" do
        expect(subject.call).to eq("a")
      end
    end

    context "when normalization method does not exist for given input type" do
      it "returns non-normalized value" do
        allow(described_class).to receive(:respond_to?).with("normalize_time").and_return(false)
        expect(subject.call).to eq("x")
      end
    end
  end

  describe "#normalization_method" do
    it "returns normalization method name built from given input type" do
      expect(subject.normalization_method).to eq("normalize_date")
    end
  end

  describe ".normalize_decimal" do
    it "returns normalized decimal value" do
      expect(described_class.normalize_decimal("1,12")).to eq(1.12.to_d)
      expect(described_class.normalize_decimal("1.298")).to eq(1.298.to_d)
    end
  end

  describe ".normalize_float" do
    it "returns normalized float value" do
      expect(described_class.normalize_float("1,12")).to eq(1.12.to_f)
      expect(described_class.normalize_float("1.298")).to eq(1.298.to_f)
    end
  end

  describe ".normalize_integer" do
    it "returns normalized integer value" do
      expect(described_class.normalize_integer("1,12")).to eq(1)
      expect(described_class.normalize_integer("4,298")).to eq(4)
    end
  end

  describe ".normalize_time" do
    it "returns value normalized with `Time.parse`" do
      allow(Time).to receive(:parse).with("a").and_return("b")
      expect(described_class.normalize_time("a")).to eq("b")
    end

    context "when empty value given" do
      it "returns nil" do
        expect(described_class.normalize_time(" ")).to be nil
        expect(described_class.normalize_time("")).to be nil
      end
    end
  end

  describe ".normalize_date" do
    it "returns value normalized with `Date.parse`" do
      allow(Date).to receive(:parse).with("a").and_return("b")
      expect(described_class.normalize_date("a")).to eq("b")
    end

    context "when empty value given" do
      it "returns nil" do
        expect(described_class.normalize_date(" ")).to be nil
        expect(described_class.normalize_date("")).to be nil
      end
    end
  end

  describe ".normalize_datetime" do
    it "returns value normalized with `DateTime.parse`" do
      allow(DateTime).to receive(:parse).with("a").and_return("b")
      expect(described_class.normalize_datetime("a")).to eq("b")
    end

    context "when empty value given" do
      it "returns nil" do
        expect(described_class.normalize_datetime(" ")).to be nil
        expect(described_class.normalize_datetime("")).to be nil
      end
    end
  end

  describe ".normalize_boolean" do
    it "returns value compared against string value of `1`" do
      expect(described_class.normalize_boolean("1")).to be true
      expect(described_class.normalize_boolean("0")).to be false
      expect(described_class.normalize_boolean("ewwqe")).to be false
      expect(described_class.normalize_boolean("")).to be false
    end
  end
end
