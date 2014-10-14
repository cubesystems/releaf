require "spec_helper"

describe Releaf::Core::SettingsFormBuilder, type: :class do
  class FormBuilderTestHelper < ActionView::Base; end
  let(:template){ FormBuilderTestHelper.new }
  let(:object){ Releaf::Settings.new }
  let(:subject){ described_class.new(:resource, object, template, {}) }

  describe "#render_value" do
    it "renders text field for value" do
      allow(subject).to receive(:releaf_text_field).with(:value).and_return("x")
      expect(subject.render_value).to eq("x")
    end
  end
end
