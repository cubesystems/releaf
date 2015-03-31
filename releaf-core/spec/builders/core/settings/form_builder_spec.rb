require "spec_helper"

describe Releaf::Core::Settings::FormBuilder, type: :class do
  class FormBuilderTestHelper < ActionView::Base; end
  before do
    Releaf::Settings.register([
      { key: "myapp.rating", default: 5.65, description: "x", type: :decimal },
      { key: "myapp.confirmed", default: true, type: :boolean },
      { key: "myapp.intro" }
    ])
  end

  let(:template){ FormBuilderTestHelper.new }

  describe "#field_names" do
    let(:subject){ described_class.new(:resource, Releaf::Settings.first, template, {}) }

    it "returns :value as only editable field within array" do
      expect(subject.field_names).to eq([:value])
    end
  end

  describe "#render_value" do
    let(:subject){ described_class.new(:resource, Releaf::Settings.first, template, {}) }

    it "renders text field for value" do
      allow(subject).to receive(:settings_field_label_text).and_return("x")
      allow(subject).to receive(:settings_field_type).and_return("text")
      allow(subject).to receive(:releaf_text_field).with(:value, { options: { label: { label_text: "x" }}}).and_return("y")
      expect(subject.render_value).to eq("y")
    end
  end

  describe "#settings_field_label_text" do
    context "when description is available" do
      let(:subject){ described_class.new(:resource, Releaf::Settings.first, template, {}) }

      it "returns translated description text" do
        allow(subject).to receive(:t).with("x", { scope: "settings"}).and_return("y")
        expect(subject.settings_field_label_text).to eq("y")
      end
    end

    context "when description is not available" do
      let(:subject){ described_class.new(:resource, Releaf::Settings.last, template, {}) }

      it "returns 'Value'" do
        expect(subject.settings_field_label_text).to eq("Value")
      end
    end
  end

  describe "#settings_field_type" do
    it "returns correct field type for the first setting" do
      subject = described_class.new(:resource, Releaf::Settings.first, template, {})
      expect(subject.settings_field_type).to eq(:decimal)
    end

    it "returns correct field type for the second setting" do
      subject = described_class.new(:resource, Releaf::Settings.second, template, {})
      expect(subject.settings_field_type).to eq(:boolean)
    end

    it "returns correct default field type" do
      subject = described_class.new(:resource, Releaf::Settings.last, template, {})
      expect(subject.settings_field_type).to eq(:text)
    end
  end
end
