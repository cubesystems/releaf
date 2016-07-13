require "rails_helper"

describe Releaf::Settings::FormBuilder, type: :class do
  class FormBuilderTestHelper < ActionView::Base; end
  let(:resource){ Releaf::Settings.new }
  let(:template){ FormBuilderTestHelper.new }
  let(:subject){ described_class.new(:resource, resource, template, {}) }

  describe "#field_names" do
    it "returns :value as only editable field within array" do
      expect(subject.field_names).to eq([:value])
    end
  end

  describe "#render_value" do
    it "renders with resolved label text and render method" do
      allow(subject).to receive(:value_label_text).and_return("x")
      allow(subject).to receive(:value_render_method_name).and_return("releaf_integer_field")
      allow(subject).to receive(:releaf_integer_field).with(:value, { options: { label: { label_text: "x" }}}).and_return("y")
      expect(subject.render_value).to eq("y")
    end
  end

  describe "#value_render_method_name" do
    it "returns render method built from input type" do
      allow(resource).to receive(:input_type).and_return(:superdate)
      expect(subject.value_render_method_name).to eq("releaf_superdate_field")
    end
  end

  describe "#value_label_text" do
    context "when description is available" do
      it "returns translated description text" do
        allow(resource).to receive(:description).and_return("x")
        allow(subject).to receive(:t).with("x", { scope: "settings"}).and_return("y")
        expect(subject.value_label_text).to eq("y")
      end
    end

    context "when description is not available" do
      it "returns translated 'value' attribute" do
        allow(subject).to receive(:translate_attribute).with(:value).and_return("xx")
        allow(resource).to receive(:description).and_return(nil)
        expect(subject.value_label_text).to eq("xx")
      end
    end
  end
end
