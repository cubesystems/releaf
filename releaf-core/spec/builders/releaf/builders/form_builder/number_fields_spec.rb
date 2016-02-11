require "rails_helper"

describe Releaf::Builders::FormBuilder::NumberFields, type: :class do
  class FormBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
    include Releaf::ButtonHelper
    include FontAwesome::Rails::IconHelper
  end

  let(:template){ FormBuilderTestHelper.new }
  let(:object){ Book.new }
  let(:subject){ Releaf::Builders::FormBuilder.new(:book, object, template, {}) }

  describe "#releaf_number_field" do
    it "returns input with type 'number'" do
      expect(subject).to receive(:number_field).with("title", { value: nil, step: "any", class: "text" }).and_return("x")
      expect(subject).to receive(:input_wrapper_with_label).with("title", "x", { label: {}, field: {}, options: { field: { type: "number" }}}).and_return("y")
      expect(subject.releaf_number_field("title")).to eq("y")
    end

    context "aliases" do
      let(:releaf_number_field_method) { subject.method(:releaf_number_field) }

      it "is aliased by #releaf_integer_field" do
        expect(subject.method(:releaf_integer_field)).to eq(releaf_number_field_method)
      end

      it "is aliased by #releaf_float_field" do
        expect(subject.method(:releaf_float_field)).to eq(releaf_number_field_method)
      end

      it "is aliased by #releaf_decimal_field" do
        expect(subject.method(:releaf_decimal_field)).to eq(releaf_number_field_method)
      end
    end
  end
end
