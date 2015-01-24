require "spec_helper"

describe Releaf::Core::PermittedParams do
  subject{ described_class.new(Book) }

  describe "#initialize" do
    it "assigns given class to resource class accessor" do
      expect(subject.resource_class).to eq(Book)
    end
  end

  describe "#excluded_attributes" do
    it "returns array with id, created_at and updated_as" do
      expect(subject.excluded_attributes).to eq(["id", "created_at", "updated_at"])
    end
  end

  describe "#file_attributes" do
    it "returns list with file attributes" do
      expect(subject.file_attributes).to eq(["cover_image_uid"])

      subject.resource_class = Node
      expect(subject.file_attributes).to eq([])
    end
  end

  describe "#file_attribute?" do
    context "when given attribute exists within file attributes" do
      it "returns true" do
        allow(subject).to receive(:file_attributes).and_return(["color"])
        expect(subject.file_attribute?("color")).to be true
      end
    end

    context "when given attribute does not exist within file attributes" do
      it "returns false" do
        allow(subject).to receive(:file_attributes).and_return(["size"])
        expect(subject.file_attribute?("color")).to be false
      end
    end
  end

  describe "#file_attribute_params" do
    it "returns array with dragonfly specific attributes" do
      expect(subject.file_attribute_params("cover_image_uid"))
        .to eq(["cover_image", "retained_cover_image", "remove_cover_image"])
    end
  end

  describe "#localized_attributes?" do
    context "when resource class has globalize support" do
      it "returns true" do
        expect(subject.localized_attributes?).to be true
      end
    end

    context "when resource class does not have globalize support" do
      it "returns false" do
        allow(subject.resource_class).to receive(:translates?).and_return(false)
        expect(subject.localized_attributes?).to be false
      end
    end
  end

  describe "#localized_attributes" do
    it "returns array of all localized attributes params" do
      allow(subject.resource_class).to receive(:translated_attribute_names).and_return(["title", "summary"])
      allow(subject).to receive(:localized_attribute_params).with("title").and_return(["t1", "t2"])
      allow(subject).to receive(:localized_attribute_params).with("summary").and_return(["s1", "s2"])
      expect(subject.localized_attributes).to eq(["t1", "t2", "s1", "s2"])

      allow(subject.resource_class).to receive(:translated_attribute_names).and_return([])
      expect(subject.localized_attributes).to eq([])
    end
  end

  describe "#localized_attribute_params" do
    it "returns array with localized attribute within all specified locales" do
      expect(subject.localized_attribute_params(:description)).to eq(["description_en", "description_lv"])

      allow(subject.resource_class).to receive(:globalize_locales).and_return(["de"])
      expect(subject.localized_attribute_params(:description)).to eq(["description_de"])
    end
  end

  describe "#base_params" do
    it "returns array with non-excluded and file attributes" do
      allow(subject.resource_class).to receive(:column_names).and_return(["a", "b", "c"])
      allow(subject).to receive(:file_attribute?).and_return(false)
      expect(subject.base_params).to eq(["a", "b", "c"])

      allow(subject).to receive(:file_attribute?).with("b").and_return(true)
      allow(subject).to receive(:file_attribute_params).with("b").and_return(["b1", "b2"])
      expect(subject.base_params).to eq(["a", "b1", "b2", "c"])

      allow(subject).to receive(:excluded_attributes).and_return(["a"])
      expect(subject.base_params).to eq(["b1", "b2", "c"])
    end
  end

  describe "#params" do
    it "returns resource params array" do
      allow(subject).to receive(:base_params).and_return(["a", "b"])
      allow(subject).to receive(:localized_attributes?).and_return(false)
      expect(subject.params).to eq(["a", "b"])
    end

    context "when resource has localized attributes" do
      it "returns resource params array alongside localized attributes" do
        allow(subject).to receive(:base_params).and_return(["a", "b"])
        allow(subject).to receive(:localized_attributes?).and_return(true)
        allow(subject).to receive(:localized_attributes).and_return(["c", "d"])
        expect(subject.params).to eq(["a", "b", "c", "d"])
      end
    end
  end
end
