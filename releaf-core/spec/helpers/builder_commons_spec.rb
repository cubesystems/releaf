require "spec_helper"

describe Releaf::BuilderCommons, type: :module do
  class FormBuilderTestHelper < ActionView::Base; end
  class BuilderCommonsIncluder
    include Releaf::BuilderCommons
    attr_accessor :template
  end

  let(:subject){ BuilderCommonsIncluder.new }
  let(:template){ FormBuilderTestHelper.new }

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

  describe "#controller" do
    it "returns template contoller" do
      allow(template).to receive(:controller).and_return("x")
      subject.template = template
      expect(subject.controller).to eq("x")
    end
  end

  describe "#tag" do
    it "passes all arguments to template #content_tag method and return result" do
      subject.template = template
      expect(subject.tag(:span, "x", class: "red")).to eq('<span class="red">x</span>')
      expect(subject.tag(:div, class: "green"){ "y" }).to eq('<div class="green">y</div>')
    end
  end
end
