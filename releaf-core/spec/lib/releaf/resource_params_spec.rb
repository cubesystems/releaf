require "rails_helper"

describe Releaf::ResourceParams do
  subject{ described_class.new(Book) }

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

  describe "#localized_attributes" do
    it "returns array of all localized attributes params" do
      allow(subject.resource_class).to receive(:translated_attribute_names).and_return(["title", "summary"])
      allow(subject).to receive(:localized_attribute_params).with("title").and_return(["t1", "t2"])
      allow(subject).to receive(:localized_attribute_params).with("summary").and_return(["s1", "s2"])
      expect(subject.localized_attributes).to eq(["t1", "t2", "s1", "s2"])

      allow(subject.resource_class).to receive(:translated_attribute_names).and_return([])
      subject.instance_variable_set("@localized_attributes", nil) # reset cached values
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

  describe "#base_attributes" do
    it "returns array with base and file attributes" do
      allow(subject.resource_class).to receive(:column_names).and_return(["a", "b", "c"])
      allow(subject).to receive(:file_attribute?).and_return(false)
      expect(subject.base_attributes).to eq(["a", "b", "c"])

      allow(subject).to receive(:file_attribute?).with("b").and_return(true)
      allow(subject).to receive(:file_attribute_params).with("b").and_return(["b1", "b2"])
      expect(subject.base_attributes).to eq(["a", "b1", "b2", "c"])
    end
  end

  describe "#values" do
    before do
      allow(subject).to receive(:associations_attributes).and_return(["x", "y"])
    end

    it "returns resource params array alongside associations params" do
      allow(subject).to receive(:base_attributes).and_return(["a", "b"])
      allow(subject).to receive(:localized_attributes?).and_return(false)
      expect(subject.values).to eq(["a", "b", "x", "y"])
    end

    context "when resource has localized attributes" do
      it "returns resource params array alongside localized attributes" do
        allow(subject).to receive(:base_attributes).and_return(["a", "b"])
        allow(subject).to receive(:localized_attributes?).and_return(true)
        allow(subject).to receive(:localized_attributes).and_return(["c", "d"])
        expect(subject.values).to eq(["a", "b", "c", "d", "x", "y"])
      end
    end
  end

  describe "#associations_attributes" do
    it "returns array with associations params within hashes" do
      association_1 = subject.resource_class.reflections["chapters"]
      association_2 = subject.resource_class.reflections["sequels"]

      allow(subject).to receive(:associations).and_return([association_1, association_2])
      allow(subject).to receive(:association_attributes).with(association_1).and_return(["a", "b"])
      allow(subject).to receive(:association_attributes).with(association_2).and_return(["c", "d"])

      expect(subject.associations_attributes).to eq([{"chapters_attributes"=>["a", "b"]}, {"sequels_attributes"=>["c", "d"]}])
    end
  end

  describe "#association_attributes" do
    it "returns association params with `id` and `_destroy` params and without `foreign_key` param" do
      association = subject.resource_class.reflections["chapters"]
      allow(association).to receive(:foreign_key).and_return("b")
      allow(described_class).to receive(:new).with(association.klass).and_call_original
      allow_any_instance_of(described_class).to receive(:values).and_return(["a", "b", "c"])
      expect(subject.association_attributes(association)).to eq(["a", "c", "id", "_destroy"])
    end
  end
end
