require 'spec_helper'

describe Releaf::ResourceValidator do

  describe ".validation_attribute_name" do
    let(:book) { Book.new }

    context "when an existing attribute name is given" do
      it "returns the given attribute" do
        expect( subject.send(:validation_attribute_name, book, :author_id) ).to eq 'author_id'
      end
    end

    context "when an association name is given and passing check_relations" do
      it "returns the corresponding foreign key attribute" do
        expect( subject.send(:validation_attribute_name, book, :author, true) ).to eq 'author_id'
      end
    end

    context "when a translated attribute name is given" do
      it "returns the given attribute" do
        expect( subject.send(:validation_attribute_name, book, :description_en) ).to eq 'description_en'
      end
    end

    context "when an invalid attribute is given" do
      it "returns nil" do
        expect( subject.send(:validation_attribute_name, book, :trololo)).to be_nil
      end
    end
  end

  describe ".single_association?" do
    context "when :belongs_to given as argument" do
      it "returns true" do
        expect(described_class.single_association?(:belongs_to)).to be_true
      end
    end

    context "when :has_one given as argument" do
      it "returns true" do
        expect(described_class.single_association?(:has_one)).to be_true
      end
    end

    context "when any other value given as argument" do
      it "returns false" do
        expect(described_class.single_association?(:has_many)).to be_false
      end
    end
  end
end
