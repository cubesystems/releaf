require "rails_helper"

describe Releaf::Settings::TableBuilder, type: :class do
  class TableBuilderTestHelper < ActionView::Base; end
  let(:template){ TableBuilderTestHelper.new }
  let(:resource_class){ Releaf::Settings }
  let(:subject){ described_class.new([], resource_class, template, {}) }

  describe "#column_names" do
    it "returns var, value and updated_at as column names array" do
      expect(subject.column_names).to eq([:var, :value, :updated_at])
    end
  end

  describe "#value_content" do
    it "return value processed with corresponding type content format method" do
      resource = Releaf::Settings.new(value: :x)
      allow(resource).to receive(:input_type).and_return(:date)
      allow(subject).to receive(:format_date_content).with(resource, :value).and_return(:y)
      expect(subject.value_content(resource)).to eq(:y)
    end
  end
end
