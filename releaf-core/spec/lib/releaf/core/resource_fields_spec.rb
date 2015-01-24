require "spec_helper"

describe Releaf::Core::ResourceFields do
  subject{ described_class.new(Book) }

  describe "#initialize" do
    it "assigns given class to resource class accessor" do
      expect(subject.resource_class).to eq(Book)
    end
  end

  describe "#excluded_attributes" do
    it "returns array with excluded attributes" do
      expect(subject.excluded_attributes)
        .to eq(%w(id created_at updated_at password password_confirmation encrypted_password item_position))
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
      allow(subject.resource_class).to receive(:translated_attribute_names).and_return([:title, :summary])
      expect(subject.localized_attributes).to eq(["title", "summary"])
    end
  end

  describe "#base_attributes" do
    it "returns array with non-excluded and file attributes" do
      allow(subject.resource_class).to receive(:column_names).and_return(["a", "b", "c"])
      expect(subject.base_attributes).to eq(["a", "b", "c"])
    end
  end

  describe "#fields" do
    it "returns resource fields array from base attributes except excluded attributes" do
      allow(subject).to receive(:base_attributes).and_return(["a", "b", "c"])
      allow(subject).to receive(:excluded_attributes).and_return(["c"])
      allow(subject).to receive(:localized_attributes?).and_return(false)
      expect(subject.fields).to eq(["a", "b"])
    end

    context "when resource has localized attributes" do
      it "returns resource base attributes array alongside localized attributes" do
        allow(subject).to receive(:base_attributes).and_return(["a", "b"])
        allow(subject).to receive(:localized_attributes?).and_return(true)
        allow(subject).to receive(:localized_attributes).and_return(["c", "d"])
        expect(subject.fields).to eq(["a", "b", "c", "d"])
      end
    end
  end
end
