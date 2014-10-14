require "spec_helper"

describe Releaf::BuilderCommons, type: :module do
  class CommonsIncluder
    include Releaf::BuilderCommons
  end
  let(:subject){ CommonsIncluder.new }

  describe "#resource_class_attributes" do
    it "returns resource columns and i18n attributes except ignorables" do
      allow(Book).to receive(:column_names).and_return(["a", "b", "c"])
      allow(subject).to receive(:resource_class_i18n_attributes).with(Book).and_return(["e", "d"])
      allow(subject).to receive(:resource_class_ignorable_attributes).with(Book).and_return(["b", "e"])

      expect(subject.resource_class_attributes(Book)).to eq(["a", "c", "d"])
    end
  end

  describe "#resource_class_ignorable_attributes" do
    it "returns array with default ignorable attributes" do
      list = ["id", "created_at", "updated_at", "password", "password_confirmation", "encrypted_password", "item_position"]
      expect(subject.resource_class_ignorable_attributes(Book)).to eq(list)
    end
  end

  describe "#resource_class_i18n_attributes" do
    context "when given resource class have i18n attributes" do
      it "returns array with i18n attributes" do
        expect(subject.resource_class_i18n_attributes(Book)).to eq(["description"])
      end
    end

    context "when given resource class don't have i18n attributes" do
      it "returns empty array" do
        expect(subject.resource_class_i18n_attributes(Author)).to eq([])
      end
    end
  end
end
